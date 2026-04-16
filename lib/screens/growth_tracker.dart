import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/models.dart';
import '../services/isar_service.dart';
import '../services/ble_service.dart';
import '../widgets/modern_notification.dart';
import 'package:audioplayers/audioplayers.dart';

import '../utils/kms_helper.dart';

class GrowthTrackerScreen extends StatefulWidget {
  const GrowthTrackerScreen({super.key});
  @override
  State<GrowthTrackerScreen> createState() => _GrowthTrackerScreenState();
}

class _GrowthTrackerScreenState extends State<GrowthTrackerScreen> {
  final int _currentIndex = 2;
  bool _isDetailView = false;
  bool _isSaving = false;
  // 0 = Berat, 1 = Tinggi, 2 = Lingkar Kepala
  int _chartTab = 0;

  List<Balita> _listBalita = [];
  Balita? _selected;
  StreamSubscription<List<Balita>>? _sub;
  StreamSubscription<String>? _sensorSub;

  final BleService _bleService = BleService();
  double _currentSensorWeight = 0.0;
  double _currentSensorHeight = 0.0;

  final TextEditingController _manualWeightController = TextEditingController();
  final TextEditingController _manualHeightController = TextEditingController();
  final TextEditingController _manualHcController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isManualInput = false;

  @override
  void initState() {
    super.initState();
    _sub = IsarService().watchAllBalita().listen((list) {
      if (mounted) {
        setState(() {
          _listBalita = list;
          if (_selected != null) {
            final found = list.where((b) => b.id == _selected!.id);
            if (found.isNotEmpty) _selected = found.first;
          }
        });
      }
    });
    void processData(String rawData) {
      if (!mounted) return;
      try {
        final parts = rawData.split(',');
        if (parts.length >= 2) {
          double? w = double.tryParse(parts[0]);
          double? h = double.tryParse(parts[1]);

          if (w != null && h != null) {
            setState(() {
              _currentSensorWeight = w;
              _currentSensorHeight = h;
            });
          }
        }
      } catch (_) {}
    }

    if (_bleService.lastData != null) {
      processData(_bleService.lastData!);
    }

    _sensorSub = _bleService.sensorDataStream.listen((rawData) {
      processData(rawData);
    });
  }

  String _formatDecimal(double val) {
    return val.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sensorSub?.cancel();
    _manualWeightController.dispose();
    _manualHeightController.dispose();
    _manualHcController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showSensorAndConfirmSheet() {
    if (_selected == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.navBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ALAT',
                        style: TextStyle(
                          color: _isManualInput
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          setModalState(() => _isManualInput = !_isManualInput);
                          try {
                            await _audioPlayer.play(
                              AssetSource('audio/toggle_click.mp3'),
                            );
                          } catch (_) {}
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 56,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _isManualInput
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isManualInput
                                            ? AppTheme.primary
                                            : Colors.black)
                                        .withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: _isManualInput
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'MANUAL',
                        style: TextStyle(
                          color: _isManualInput
                              ? AppTheme.primary
                              : Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      image:
                          (_selected!.fotoProfile != null &&
                              _selected!.fotoProfile!.isNotEmpty)
                          ? DecorationImage(
                              image: FileImage(File(_selected!.fotoProfile!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child:
                        (_selected!.fotoProfile == null ||
                            _selected!.fotoProfile!.isEmpty)
                        ? Icon(
                            Icons.child_care,
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selected!.nama ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isManualInput)
                    StreamBuilder<String>(
                      stream: _bleService.sensorDataStream,
                      builder: (context, snapshot) {
                        return Row(
                          children: [
                            _buildLiveCard(
                              'BERAT',
                              _formatDecimal(_currentSensorWeight),
                              'kg',
                              Icons.monitor_weight_outlined,
                            ),
                            const SizedBox(width: 16),
                            _buildLiveCard(
                              'TINGGI',
                              _formatDecimal(_currentSensorHeight),
                              'cm',
                              Icons.straighten_outlined,
                            ),
                          ],
                        );
                      },
                    )
                  else
                    Column(
                      children: [
                        _buildManualTextField(
                          controller: _manualWeightController,
                          label: 'Berat Badan',
                          unit: 'kg',
                          icon: Icons.monitor_weight_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildManualTextField(
                          controller: _manualHeightController,
                          label: 'Tinggi Badan',
                          unit: 'cm',
                          icon: Icons.straighten_outlined,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildManualTextField(
                    controller: _manualHcController,
                    label: 'Lingkar Kepala',
                    unit: 'cm',
                    icon: Icons.radio_button_unchecked,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setModalState(() => _isSaving = true);
                            bool success = await _handleDirectSave(
                              isManual: _isManualInput,
                            );
                            if (!context.mounted) return;
                            if (success) {
                              Navigator.pop(context);
                            }
                            setModalState(() => _isSaving = false);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'KONFIRMASI & SIMPAN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'BATAL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualTextField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                suffixText: unit,
                suffixStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _handleDirectSave({bool isManual = false}) async {
    if (_selected == null) return false;

    double weight = 0.0;
    double height = 0.0;
    double headCirc = 0.0;

    if (isManual) {
      String wStr = _manualWeightController.text.replaceAll(',', '.');
      String hStr = _manualHeightController.text.replaceAll(',', '.');
      weight = double.tryParse(wStr) ?? 0.0;
      height = double.tryParse(hStr) ?? 0.0;

      if (weight <= 0 || height <= 0) {
        ModernNotification.show(
          context,
          'Masukkan nilai berat dan tinggi yang valid!',
        );
        return false;
      }
    } else {
      weight = _currentSensorWeight;
      height = _currentSensorHeight;
    }

    String hcStr = _manualHcController.text.replaceAll(',', '.');
    headCirc = double.tryParse(hcStr) ?? 0.0;

    final riwayat = Riwayat(
      tanggal: DateTime.now().toIso8601String().substring(0, 10),
      berat: weight,
      tinggi: height,
      lingkarKepala: headCirc > 0 ? headCirc : null,
    );

    _selected!.berat = weight;
    _selected!.tinggi = height;
    String status = KmsHelper.calculateDbStatus(_selected!);
    _selected!.keterangan = status;

    await IsarService().addRiwayat(_selected!, riwayat);

    if (isManual) {
      _manualWeightController.clear();
      _manualHeightController.clear();
    }
    _manualHcController.clear();

    if (mounted) {
      ModernNotification.show(
        context,
        'Data ${_selected!.nama} disimpan. Status: ${_selected!.displayStatus}',
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isDetailView) ...[
                            _buildWelcomeText(),
                            const SizedBox(height: 16),
                            _buildToddlerList(),
                          ] else ...[
                            _buildDetailView(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex == index) return;
                if (index == 0) {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/toddler_data');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/export');
                }
              },
              onAddTap: () => Navigator.pushNamed(context, '/input'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AppBar(
      title: Text(_isDetailView ? 'Detail Pertumbuhan' : 'Growth Tracker'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: _isDetailView
          ? IconButton(
              onPressed: () => setState(() => _isDetailView = false),
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      actions: [
        IconButton(
          onPressed: () async {
            final picked = await showModalBottomSheet<Balita>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              showDragHandle: true,
              useSafeArea: true,
              builder: (_) => _BalitaSearchSheet(balitas: _listBalita),
            );
            if (picked != null) {
              setState(() {
                _selected = picked;
                _isDetailView = true;
              });
            }
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Anak',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pilih anak untuk melihat riwayat pertumbuhan',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildToddlerList() {
    if (_listBalita.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text('Belum ada data balita.'),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _listBalita.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final balita = _listBalita[index];
        final bool isGirl = (balita.jenisKelamin ?? '') == 'P';
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isGirl ? Colors.pink.shade50 : Colors.blue.shade50,
                image:
                    (balita.fotoProfile != null &&
                        balita.fotoProfile!.isNotEmpty)
                    ? DecorationImage(
                        image: FileImage(File(balita.fotoProfile!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (balita.fotoProfile == null || balita.fotoProfile!.isEmpty)
                  ? Icon(
                      Icons.child_care,
                      color: isGirl ? Colors.pink : Colors.blue,
                    )
                  : null,
            ),
            title: Text(
              balita.nama ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${balita.usia ?? 0} Bulan · ${balita.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Data Balita?'),
                        content: Text(
                          'Seluruh data riwayat ${balita.nama} juga akan terhapus secara permanen.',
                        ),
                        actionsAlignment: MainAxisAlignment.end,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await IsarService().deleteBalita(balita.id);
                      if (!context.mounted) return;
                      ModernNotification.show(
                        context,
                        'Data ${balita.nama} dihapus.',
                      );
                    }
                  },
                ),
                const Icon(Icons.chevron_right, color: AppTheme.primary),
              ],
            ),
            onTap: () => setState(() {
              _selected = balita;
              _isDetailView = true;
            }),
          ),
        );
      },
    );
  }

  Widget _buildDetailView() {
    if (_selected == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIdentityCard(),
        const SizedBox(height: 16),
        _buildCurrentStats(),
        const SizedBox(height: 20),
        _buildKmsChartSection(),
        const SizedBox(height: 20),
        _buildRecommendationsSection(),
        const SizedBox(height: 20),
        _buildMonthlyHistorySection(),
        const SizedBox(height: 20),
        _buildInputButton(),
      ],
    );
  }

  Widget _buildIdentityCard() {
    if (_selected == null) return const SizedBox();
    final bool isGirl = _selected!.jenisKelamin == 'P';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isGirl ? Colors.pink.shade50 : Colors.blue.shade50,
                image:
                    (_selected!.fotoProfile != null &&
                        _selected!.fotoProfile!.isNotEmpty)
                    ? DecorationImage(
                        image: FileImage(File(_selected!.fotoProfile!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  (_selected!.fotoProfile == null ||
                      _selected!.fotoProfile!.isEmpty)
                  ? Icon(
                      Icons.child_care,
                      color: isGirl ? Colors.pink : Colors.blue,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected!.nama ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selected!.usia ?? 0} Bulan · ${isGirl ? 'Perempuan' : 'Laki-laki'}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStats() {
    final riwayat = _selected!.riwayat ?? [];
    final lastLk = riwayat.isNotEmpty
        ? riwayat.last.lingkarKepala
        : null;
    final prevLk = riwayat.length >= 2
        ? riwayat[riwayat.length - 2].lingkarKepala
        : null;
    String lkTrend = '';
    if (lastLk != null && prevLk != null) {
      if (lastLk > prevLk) lkTrend = ' ↑';
      else if (lastLk < prevLk) lkTrend = ' ↓';
      else lkTrend = ' →';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Berat Badan',
                  '${_formatDecimal(_selected!.berat ?? 0.0)} kg',
                  Icons.monitor_weight_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Tinggi Badan',
                  '${_formatDecimal(_selected!.tinggi ?? 0.0)} cm',
                  Icons.straighten_outlined,
                ),
              ),
            ],
          ),
          if (lastLk != null) ...[
            const SizedBox(height: 12),
            _buildStatCard(
              'Lingkar Kepala$lkTrend',
              '${_formatDecimal(lastLk)} cm',
              Icons.radio_button_unchecked,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKmsChartSection() {
    final riwayat = _selected!.riwayat;
    final isGirl = _selected!.jenisKelamin == 'P';
    final hasLkData =
        riwayat?.any((r) => (r.lingkarKepala ?? 0) > 0) ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Pertumbuhan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(_selected!.nama ?? '').split(' ').first} · ${isGirl ? 'Perempuan' : 'Laki-laki'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tab selector
            SegmentedButton<int>(
              segments: [
                const ButtonSegment(
                  value: 0,
                  label: Text('Berat'),
                  icon: Icon(Icons.monitor_weight),
                ),
                const ButtonSegment(
                  value: 1,
                  label: Text('Tinggi'),
                  icon: Icon(Icons.straighten),
                ),
                ButtonSegment(
                  value: 2,
                  label: const Text('LK'),
                  icon: const Icon(Icons.radio_button_unchecked),
                  enabled: hasLkData,
                ),
              ],
              selected: {_chartTab},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _chartTab = newSelection.first;
                });
              },
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: (riwayat?.isEmpty ?? true)
                  ? const Center(
                      child: Text(
                        'Belum ada data riwayat',
                        style: TextStyle(color: Colors.black38),
                      ),
                    )
                  : _chartTab == 2
                  ? (!hasLkData
                      ? const Center(
                          child: Text(
                            'Belum ada data lingkar kepala',
                            style: TextStyle(color: Colors.black38),
                          ),
                        )
                      : CustomPaint(
                          painter: _HcChartPainter(
                            riwayat: riwayat ?? [],
                          ),
                          child: const SizedBox.expand(),
                        ))
                  : CustomPaint(
                      painter: _KmsChartPainter(
                        riwayat: riwayat ?? [],
                        whoRef: _chartTab == 0
                            ? KmsHelper.getReference(isGirl ? 'P' : 'L')
                            : KmsHelper.getHeightReference(
                                isGirl ? 'P' : 'L'),
                        showWeight: _chartTab == 0,
                      ),
                      child: const SizedBox.expand(),
                    ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legend(AppTheme.primary, 'Data Anak'),
                  if (_chartTab == 0) ...[
                    const SizedBox(width: 16),
                    _legend(Colors.green.shade300, 'Normal'),
                    const SizedBox(width: 16),
                    _legend(Colors.red.shade300, 'Batas'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyHistorySection() {
    final riwayatList = List<Riwayat>.from((_selected!.riwayat ?? []).reversed);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pemeriksaan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Tanggal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'BB',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'TB',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'LK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                ...riwayatList.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  final idx = (_selected!.riwayat?.length ?? 0) - 1 - i;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: i % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            r.tanggal ?? '-',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${r.berat}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${r.tinggi}',
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            r.lingkarKepala != null
                                ? _formatDecimal(r.lingkarKepala!)
                                : '-',
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus?'),
                                      content: const Text(
                                        'Hapus data pemeriksaan ini?',
                                      ),
                                      actionsAlignment: MainAxisAlignment.end,
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await IsarService().deleteRiwayat(
                                      _selected!,
                                      idx,
                                    );
                                    if (!mounted) return;
                                    ModernNotification.show(
                                      context,
                                      'Riwayat dihapus.',
                                    );
                                  }
                                },
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    // Use Helper for computing WHO status
    String keterangan = KmsHelper.calculateDbStatus(_selected!);

    String detailRec = '';
    Color recColor = AppTheme.primary;
    IconData recIcon = Icons.check_circle_outline;
    String statusTitle = '';

    switch (keterangan) {
      case 'Berat Rendah':
        statusTitle = 'Nutrisi Kurang Optimal';
        detailRec =
            'Berat badan di bawah standar KMS. Berikan asupan protein lebih banyak dan segera konsultasikan ke tenaga kesehatan.';
        recColor = AppTheme.statusDanger;
        recIcon = Icons.warning_amber_outlined;
        break;
      case 'Berat Lebih':
        statusTitle = 'Nutrisi Berlebih';
        detailRec =
            'Berat badan di atas standar KMS. Atur pola makan seimbang, kurangi gula berlebih, dan konsultasikan pola nutrisi anak.';
        recColor = AppTheme.statusWarning;
        recIcon = Icons.info_outline;
        break;
      case 'Data Kosong':
        statusTitle = 'Belum Ada Data';
        detailRec =
            'Lakukan pemeriksaan bulanan untuk memantau tumbuh kembang anak.';
        recColor = Colors.grey;
        recIcon = Icons.help_outline;
        break;
      case 'Sehat':
      default:
        statusTitle = 'Nutrisi Optimal';
        detailRec =
            'Tumbuh kembang anak terpantau sangat baik dan sesuai dengan kurva normal KMS.';
        recColor = AppTheme.primary;
        recIcon = Icons.check_circle_outline;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: recColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: recColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(recIcon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: recColor == Colors.grey
                          ? Colors.black54
                          : recColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detailRec,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _showSensorAndConfirmSheet,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add_chart),
        label: const Text('Input Perkembangan Bulanan'),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _KmsChartPainter extends CustomPainter {
  final List<Riwayat> riwayat;
  final Map<int, List<double>> whoRef;
  final bool showWeight;
  _KmsChartPainter({
    required this.riwayat,
    required this.whoRef,
    required this.showWeight,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (riwayat.isEmpty) return;
    const double padL = 35, padR = 10, padT = 10, padB = 25;
    final double chartW = size.width - padL - padR,
        chartH = size.height - padT - padB;

    // --- Autoscale: hitung minY & maxY dari data aktual ---
    final allValues = <double>[];
    // Tambahkan semua nilai riwayat anak
    for (final r in riwayat) {
      final v = showWeight ? (r.berat ?? 0) : (r.tinggi ?? 0);
      if (v > 0) allValues.add(v);
    }
    // Tambahkan semua titik referensi WHO hanya untuk Berat (Tinggi tidak pakai KMS)
    if (showWeight) {
      for (final refs in whoRef.values) {
        allValues.addAll(refs);
      }
    }

    double minY, maxY;
    if (allValues.isEmpty) {
      // fallback default jika tidak ada data sama sekali
      minY = showWeight ? 0 : 40;
      maxY = showWeight ? 30 : 130;
    } else {
      double rawMin = allValues.reduce(math.min);
      double rawMax = allValues.reduce(math.max);
      // Padding 15% agar garis tidak menempel ke tepi
      final pad = (rawMax - rawMin) * 0.15 + 1.0;
      minY = (rawMin - pad).clamp(0.0, double.infinity);
      maxY = rawMax + pad;
      // Untuk berat, mulai dari 0 jika batas bawah masih dekat 0
      if (showWeight && minY < 5) minY = 0;
    }
    final double rangeY = (maxY - minY) > 0 ? (maxY - minY) : 1;

    double xOf(int month) => padL + (month / 60) * chartW;
    double yOf(double v) => padT + (1 - (v - minY) / rangeY) * chartH;

    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;
    for (int yi = 0; yi <= 5; yi++) {
      double dy = padT + (yi / 5) * chartH;
      canvas.drawLine(Offset(padL, dy), Offset(padL + chartW, dy), gridPaint);
      final labelVal = maxY - (yi / 5) * rangeY;
      // Tampilkan desimal hanya bila range sempit (< 15 unit)
      final labelStr = labelVal.toStringAsFixed(rangeY < 15 ? 1 : 0);
      _drawText(
        canvas,
        labelStr,
        Offset(5, dy - 6),
        8,
        Colors.black38,
      );
    }
    for (int xi = 0; xi <= 6; xi++) {
      double dx = padL + (xi / 6) * chartW;
      canvas.drawLine(Offset(dx, padT), Offset(dx, padT + chartH), gridPaint);
      _drawText(
        canvas,
        '${xi * 10}b',
        Offset(dx - 8, size.height - 18),
        8,
        Colors.black38,
      );
    }
    final keys = whoRef.keys.toList()..sort();
    void drawWhoLine(int refIdx, Color color) {
      final p = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (int i = 0; i < keys.length; i++) {
        double x = xOf(keys[i]), y = yOf(whoRef[keys[i]]![refIdx]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, p);
    }

    // Gambar garis KMS hanya saat mode Berat
    if (showWeight) {
      drawWhoLine(0, Colors.red);
      drawWhoLine(1, Colors.green);
      drawWhoLine(2, Colors.blue);
    }
    final childPaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    bool isFirstPoint = true;
    for (int i = 0; i < riwayat.length; i++) {
      try {
        final v = showWeight ? riwayat[i].berat : riwayat[i].tinggi;
        if (v == null || v <= 0) continue;

        DateTime dt = DateTime.parse(riwayat[i].tanggal!);
        DateTime start = DateTime.parse(riwayat.first.tanggal!);
        int months = (dt.difference(start).inDays / 30).floor().clamp(0, 60);
        double x = xOf(months), y = yOf(v);
        
        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = AppTheme.primary);
      } catch (_) {}
    }
    canvas.drawPath(path, childPaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double size,
    Color color,
  ) {
    TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size, color: color),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _KmsChartPainter old) => true;
}

// ──────────────────────────────────────────────
// HC (Lingkar Kepala) Tren Chart — tanpa referensi WHO
// ──────────────────────────────────────────────
class _HcChartPainter extends CustomPainter {
  final List<Riwayat> riwayat;
  _HcChartPainter({required this.riwayat});

  @override
  void paint(Canvas canvas, Size size) {
    // Kumpulkan data LK yang valid
    final lkData = riwayat
        .where((r) => (r.lingkarKepala ?? 0) > 0 && r.tanggal != null)
        .toList();
    if (lkData.isEmpty) return;

    const double padL = 35, padR = 10, padT = 10, padB = 25;
    final double chartW = size.width - padL - padR;
    final double chartH = size.height - padT - padB;

    // Autoscale
    final allLk = lkData.map((r) => r.lingkarKepala!).toList();
    final rawMin = allLk.reduce(math.min);
    final rawMax = allLk.reduce(math.max);
    final pad = (rawMax - rawMin) * 0.2 + 1.0;
    final minY = (rawMin - pad).clamp(0.0, double.infinity);
    final maxY = rawMax + pad;
    final rangeY = (maxY - minY) > 0 ? (maxY - minY) : 1.0;

    // Sumbu X berdasarkan urutan kunjungan (0..n-1)
    final n = lkData.length;
    double xOf(int i) => padL + (n <= 1 ? 0.5 : i / (n - 1)) * chartW;
    double yOf(double v) => padT + (1 - (v - minY) / rangeY) * chartH;

    // Grid horizontal
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;
    for (int yi = 0; yi <= 5; yi++) {
      double dy = padT + (yi / 5) * chartH;
      canvas.drawLine(Offset(padL, dy), Offset(padL + chartW, dy), gridPaint);
      final labelVal = maxY - (yi / 5) * rangeY;
      final labelStr = labelVal.toStringAsFixed(1);
      TextPainter(
        text: TextSpan(
          text: labelStr,
          style: const TextStyle(fontSize: 8, color: Colors.black38),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(5, dy - 6));
    }

    // Data points & garis
    final linePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (int i = 0; i < lkData.length; i++) {
      final x = xOf(i);
      final y = yOf(lkData[i].lingkarKepala!);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = AppTheme.primary);

      // Label tanggal di bawah
      final label = (lkData[i].tanggal ?? '').length >= 7
          ? lkData[i].tanggal!.substring(5) // MM-DD
          : (lkData[i].tanggal ?? '');
      TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 7, color: Colors.black38),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(x - 12, size.height - 18));
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _HcChartPainter old) => true;
}

class _BalitaSearchSheet extends StatefulWidget {
  final List<Balita> balitas;
  const _BalitaSearchSheet({required this.balitas});
  @override
  State<_BalitaSearchSheet> createState() => _BalitaSearchSheetState();
}

class _BalitaSearchSheetState extends State<_BalitaSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Balita> _filtered = [];
  @override
  void initState() {
    super.initState();
    _filtered = widget.balitas;
    _searchCtrl.addListener(() {
      setState(() {
        _filtered = widget.balitas
            .where(
              (b) => (b.nama ?? '').toLowerCase().contains(
                _searchCtrl.text.toLowerCase(),
              ),
            )
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            controller: _searchCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari nama balita...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _filtered.length,
              separatorBuilder: (context, i) => const Divider(),
              itemBuilder: (context, i) {
                final b = _filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        (b.fotoProfile != null && b.fotoProfile!.isNotEmpty)
                        ? FileImage(File(b.fotoProfile!))
                        : null,
                  ),
                  title: Text(b.nama ?? ''),
                  subtitle: Text('${b.usia} Bulan'),
                  onTap: () => Navigator.pop(context, b),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Modern Top Notification Widget
// ──────────────────────────────────────────────
class _ModernNotification extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ModernNotification({required this.message, required this.onDismiss});
  @override
  State<_ModernNotification> createState() => _ModernNotificationState();
}

class _ModernNotificationState extends State<_ModernNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.navBackground.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                onPressed: () {
                  _controller.reverse().then((_) => widget.onDismiss());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
