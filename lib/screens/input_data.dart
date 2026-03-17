import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/models.dart';
import '../services/ble_service.dart';
import '../services/isar_service.dart';
import '../widgets/modern_notification.dart';

// WHO reference logic to ensure data consistency
const Map<int, List<double>> _whoBoysW = {
  0: [2.5, 3.3, 4.4],
  3: [4.4, 6.0, 7.8],
  6: [6.0, 7.9, 9.8],
  9: [7.1, 9.2, 11.4],
  12: [7.8, 10.2, 12.5],
  15: [8.4, 11.0, 13.5],
  18: [8.8, 11.6, 14.2],
  21: [9.2, 12.2, 14.9],
  24: [9.7, 12.9, 15.7],
  27: [10.0, 13.5, 16.5],
  30: [10.4, 14.0, 17.2],
  36: [11.0, 15.0, 18.4],
  42: [11.6, 16.0, 19.7],
  48: [12.1, 16.9, 20.8],
  54: [12.7, 17.8, 21.9],
  60: [13.1, 18.7, 23.1],
};
const Map<int, List<double>> _whoGirlsW = {
  0: [2.4, 3.2, 4.2],
  3: [4.2, 5.7, 7.4],
  6: [5.7, 7.5, 9.4],
  9: [6.8, 8.9, 11.1],
  12: [7.3, 9.7, 12.1],
  15: [7.8, 10.5, 13.0],
  18: [8.2, 11.0, 13.7],
  21: [8.7, 11.6, 14.4],
  24: [9.1, 12.2, 15.2],
  27: [9.5, 12.8, 16.0],
  30: [9.9, 13.4, 16.7],
  36: [10.5, 14.3, 17.9],
  42: [11.1, 15.2, 19.0],
  48: [11.6, 16.0, 20.1],
  54: [12.1, 16.9, 21.2],
  60: [12.7, 17.7, 22.2],
};

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({Key? key}) : super(key: key);

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  int _currentIndex = -1;
  int? _selectedBalitaId;
  List<Balita> _listBalita = [];
  StreamSubscription<List<Balita>>? _sub;

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
    _bleService.sensorDataStream.listen((dataString) {
      if (mounted) {
        try {
          final parts = dataString.split(',');
          if (parts.length >= 2) {
            setState(() {
              _currentWeight = double.parse(parts[0]);
              _currentHeight = double.parse(parts[1]);
            });
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
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
    setState(() => _isSaving = true);

    final riwayat = Riwayat(
      tanggal: DateTime.now().toIso8601String().substring(0, 10),
      berat: _currentWeight,
      tinggi: _currentHeight,
    );

    // Calculate status directly for consistency
    final isGirl = _selectedBalita!.jenisKelamin == 'P';
    final whoRef = isGirl ? _whoGirlsW : _whoBoysW;
    final ages = whoRef.keys.toList()..sort();

    int ageIdx = ages.first;
    double minDiff = double.maxFinite;
    for (int a in ages) {
      double diff = (a - (_selectedBalita!.usia ?? 0)).abs().toDouble();
      if (diff < minDiff) {
        minDiff = diff;
        ageIdx = a;
      }
    }
    final ref = whoRef[ageIdx]!;

    String status = 'Sehat';
    if (_currentWeight < ref[0])
      status = 'Berat Rendah';
    else if (_currentWeight > ref[2])
      status = 'Berat Lebih';

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
                setState(() => _currentIndex = index);
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/');
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'CONNECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
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
                    child: _buildSensorColumn(
                      'Weight',
                      'BLE V2',
                      _currentWeight.toStringAsFixed(1),
                      'kg',
                      Icons.monitor_weight_outlined,
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
                      _currentHeight.toStringAsFixed(1),
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
                                  '$_currentWeight kg',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sblm: ${(_selectedBalita?.riwayat?.isNotEmpty ?? false) ? (_selectedBalita!.riwayat!.last.berat ?? 0.0) : 0.0} kg',
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
                                  '$_currentHeight cm',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sblm: ${(_selectedBalita?.riwayat?.isNotEmpty ?? false) ? (_selectedBalita!.riwayat!.last.tinggi ?? 0.0) : 0.0} cm',
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
                                if (mounted)
                                  setModalState(() => _isSaving = false);
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
            final isGirl = balita.jenisKelamin == 'P';
            final whoRef = isGirl ? _whoGirlsW : _whoBoysW;
            final ages = whoRef.keys.toList()..sort();
            int ageIdx = ages.first;
            double minDiff = double.maxFinite;
            for (int a in ages) {
              double diff = (a - (balita.usia ?? 0)).abs().toDouble();
              if (diff < minDiff) {
                minDiff = diff;
                ageIdx = a;
              }
            }
            final ref = whoRef[ageIdx]!;

            Color statusColor = AppTheme.primary;
            if (balita.berat != null && balita.berat! > 0) {
              if (balita.berat! < ref[0])
                statusColor = AppTheme.statusDanger;
              else if (balita.berat! > ref[2])
                statusColor = AppTheme.statusWarning;
            } else {
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
                              image: DecorationImage(
                                image:
                                    (balita.fotoProfile != null &&
                                        balita.fotoProfile!.isNotEmpty)
                                    ? FileImage(File(balita.fotoProfile!))
                                    : NetworkImage(
                                            'https://mighty.tools/mockmind-api/content/human/${((balita.nama ?? '').length % 50) + 10}.jpg',
                                          )
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
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
