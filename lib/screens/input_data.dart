import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/models.dart';
import '../services/ble_service.dart';
*port '../services/app_settings_service.dart';
import '../services/isar_service.dart';
import '../widgets/modern_notification.dart';

import '../utils/kms_helper.dart';

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({super.key});

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  int _currentIndex = -1;
  int? _selectedBalitaId;
  List<Balita> _listBalita = [];
  StreamSubscription<List<Balita>>? _sub;
  StreamSubscription<String>? _bleSub;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Balita? get _selectedBalita => _selectedBalitaId == null
      ? null
      : _listBalita.firstWhere(
          (b) => b.id == _selectedBalitaId,
          orElse: () => Balita(),
        );

  final BleService _bleService = BleService();

  double _currentWeight = 0.0;
  double _currentHeight = 0.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // 1. GUARANTEED BLE REGISTRATION
    try {
      bool _hasShownSnackbar = false;
      void processDataString(String dataString) {
        if (!mounted) return;
        try {
          final parts = dataString.split(',');
          if (parts.length >= 2) {
            double? w = double.tryParse(parts[0]);
            double? h = double.tryParse(parts[1]);

            print("BLE UI_LISTENER: Parsed -> w=$w, h=$h");

            if (w != null && h != null) {
              setState(() {
                _currentWeight = w;
                _currentHeight = h;
              });
              print("BLE UI_LISTENER: ⭐ SETSTATE CALLED! UI WILL REBUILD! ⭐");

              if (!_hasShownSnackbar) {
                _hasShownSnackbar = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('BLE Data Mendarat! Berat: $w, Tinggi: $h'),
                  ),
                );
              }
            }
          }
        } catch (e) {
          print("BLE UI_LISTENER: Error -> $e");
        }
      }

      if (_bleService.lastData != null) {
        print(
          "BLE UI_LISTENER: Found cached lastData -> ${_bleService.lastData}",
        );
        processDataString(_bleService.lastData!);
      }

      _bleSub = _bleService.sensorDataStream.listen((dataString) {
        print("BLE UI_LISTENER: Received -> $dataString");
        processDataString(dataString);
      });
      print("BLE UI_LISTENER: ✅ Successfully registered BLE Data Stream.");
    } catch (e) {
      print("BLE UI_LISTENER: CRITICAL ERROR IN BLE INIT: $e");
    }

    // 2. ISAR REGISTRATION
    try {
      _sub = IsarService().watchAllBalita().listen((list) {
        if (mounted) {
          setState(() {
            _listBalita = list;
            if (_selectedBalitaId != null &&
                !list.any((b) => b.id == _selectedBalitaId)) {
              _selectedBalitaId = null;
            }
          });
        }
      });
    } catch (e) {
      print("ISAR ERROR in InputDataScreen: $e");
    }
  }

  String _formatDecimal(double val) {
    return val.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _initial(String? text, {String fallback = 'B'}) {
    final value = (text ?? '').trim();
    if (value.isEmpty) return fallback;
    return value[0].toUpperCase();
  }

  @override
  void dispose() {
    _bleSub?.cancel();
    _sub?.cancel();
    _bleService.disconnect();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveDataToIsar() async {
    if (_selectedBalita == null) {
      ModernNotification.show(context, 'Pilih balita terlebih dahulu!');
      return;
    }
    final settings = AppSettingsService().settings;
    if (settings.confirmBeforeSave) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Simpan'),
          content: Text(
            'Simpan berat ${_formatDecimal(_currentWeight)} kg dan tinggi ${_formatDecimal(_currentHeight)} cm untuk ${_selectedBalita?.nama ?? 'balita'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yakin'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    setState(() => _isSaving = true);

    final riwayat = Riwayat(
      tanggal: DateTime.now().toIso8601String().substring(0, 10),
      berat: _currentWeight,
      tinggi: _currentHeight,
    );

    String status = KmsHelper.calculateDbStatus(
      _selectedBalita!,
      overrideWeight: _currentWeight,
    );
    _selectedBalita!.keterangan = status;
    await IsarService().addRiwayat(_selectedBalita!, riwayat);

    setState(() => _isSaving = false);
    if (mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ModernNotification.show(context, 'Data berhasil disimpan!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildLiveSensorData(),
                    const SizedBox(height: 24),
                    _buildToddlerSelector(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 110,
              right: 24,
              child: _buildFloatingAddToddlerButton(),
            ),
            CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex == index) return;
                switch (index) {
                  case 0:
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/toddler_data');
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/growth');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/export');
                    break;
                }
              },
              onAddTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'E-POSYANDU',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Digital Health Monitoring',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          Badge(
            isLabelVisible: _listBalita.any((b) => b.keterangan != 'Sehat'),
            backgroundColor: AppTheme.statusDanger,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSensorData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE SENSOR DATA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
              StreamBuilder<BluetoothConnectionState>(
                stream: _bleService.connectionStateStream,
                initialData: BluetoothConnectionState.disconnected,
                builder: (context, snapshot) {
                  final isConnected =
                      snapshot.data == BluetoothConnectionState.connected;
                  return Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected ? AppTheme.primary : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'CONNECTED' : 'DISCONNECTED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? AppTheme.primary : Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        _buildSensorColumn(
                          'Weight',
                          'BLE V2',
                          _formatDecimal(_currentWeight),
                          'kg',
                          Icons.monitor_weight_outlined,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            onPressed: () {
                              _bleService.sendCommand("tare");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mengirim perintah Tare...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.exposure_zero, size: 20),
                            color: AppTheme.primary,
                            tooltip: 'Reset Berat (Tare)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    thickness: 2,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSensorColumn(
                      'Height',
                      'ULTRA V1',
                      _formatDecimal(_currentHeight),
                      'cm',
                      Icons.straighten_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorColumn(
    String title,
    String version,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            version,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSaveBottomSheet() {
    if (_selectedBalitaId == null || _selectedBalita == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.navBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SIMPAN DATA PENGUKURAN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedBalita?.nama ?? 'Balita',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${_selectedBalita?.usia ?? 0} bulan • ${(_selectedBalita?.jenisKelamin ?? '') == 'P' ? 'Perempuan' : 'Laki-laki'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            image:
                                (_selectedBalita?.fotoProfile != null &&
                                    _selectedBalita!.fotoProfile!.isNotEmpty)
                                ? DecorationImage(
                                    image: FileImage(
                                      File(_selectedBalita!.fotoProfile!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child:
                              (_selectedBalita?.fotoProfile == null ||
                                  _selectedBalita!.fotoProfile!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  size: 30,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Berat Terbaca',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDecimal(_currentWeight)} kg',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sblm: ${(_selectedBalita?.riwayat?.isNotEmpty ?? false) ? _formatDecimal(_selectedBalita!.riwayat!.last.berat ?? 0.0) : _formatDecimal(0.0)} kg',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tinggi Terbaca',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDecimal(_currentHeight)} cm',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sblm: ${(_selectedBalita?.riwayat?.isNotEmpty ?? false) ? _formatDecimal(_selectedBalita!.riwayat!.last.tinggi ?? 0.0) : _formatDecimal(0.0)} cm',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setModalState(() => _isSaving = true);
                              _saveDataToIsar().then((_) {
                                if (mounted) {
                                  setModalState(() => _isSaving = false);
                                }
                              });
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Data',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToddlerSelector() {
    final filteredList = _listBalita
        .where(
          (balita) => (balita.nama ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'REGISTERED TODDLERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Cari nama balita...',
            leading: const Icon(Icons.search, color: Colors.black38, size: 20),
            backgroundColor: WidgetStateProperty.all(
              Colors.white.withValues(alpha: 0.6),
            ),
            elevation: WidgetStateProperty.all(0),
            side: WidgetStateProperty.all(
              BorderSide(color: AppTheme.primary.withValues(alpha: 0.1)),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
            trailing: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.black38,
                    size: 16,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final balita = filteredList[index];
            final isSelected = _selectedBalitaId == balita.id;

            // Calculate status for indicator
            final String ds = balita.displayStatus;
            Color statusColor = AppTheme.primary;
            if (ds == 'Kurang Optimal') {
              statusColor = AppTheme.statusDanger;
            } else if (ds == 'Berlebih') {
              statusColor = AppTheme.statusWarning;
            } else if (ds == 'Data Kosong' || ds == '-') {
              statusColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedBalitaId = balita.id);
                  _showSaveBottomSheet();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.white.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ],
                              image: (balita.fotoProfile != null &&
                                      balita.fotoProfile!.isNotEmpty)
                                  ? DecorationImage(
                                      image: FileImage(File(balita.fotoProfile!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (balita.fotoProfile == null ||
                                    balita.fotoProfile!.isEmpty)
                                ? Center(
                                    child: Text(
                                      _initial(balita.nama),
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              balita.nama ?? 'Nama Anak',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${balita.usia ?? 0} Bulan • ID: ${(balita.tanggalDaftar ?? '').isNotEmpty ? (balita.tanggalDaftar ?? '').substring(0, 4) : "0000"}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (balita.keterangan ?? '-').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle : Icons.chevron_right,
                        color: isSelected ? AppTheme.primary : Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloatingAddToddlerButton() {
    return FloatingActionButton(
      heroTag: 'add_toddler',
      onPressed: () => Navigator.pushNamed(context, '/register'),
      backgroundColor: AppTheme.primary,
      child: const Icon(
        Icons.person_add,
        color: AppTheme.navBackground,
        size: 28,
      ),
    );
  }
}
