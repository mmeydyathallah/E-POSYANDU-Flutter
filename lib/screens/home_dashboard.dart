import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/ble_service.dart';
import '../services/app_settings_service.dart';
import '../services/isar_service.dart';
import '../models/models.dart';
import '../widgets/modern_notification.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;
  final BleService _bleService = BleService();
  List<Balita> _listBalita = [];

  double _sensorWeight = 0.0;
  double _sensorHeight = 0.0;

  bool _isConnected = false;
  bool _isScanning = false;
  String _connectionStatus = 'Tidak Terhubung';
  final AppSettingsService _settingsService = AppSettingsService();
  bool _autoConnectSheetShown = false;

  @override
  void initState() {
    super.initState();
    IsarService().watchAllBalita().listen((data) {
      if (mounted) {
        setState(() {
          data.sort((a, b) {
            if ((a.riwayat?.isEmpty ?? true) && (b.riwayat?.isEmpty ?? true))
              return b.id.compareTo(a.id);
            if (a.riwayat?.isEmpty ?? true) return 1;
            if (b.riwayat?.isEmpty ?? true) return -1;
            return b.riwayat!.last.tanggal!.compareTo(a.riwayat!.last.tanggal!);
          });
          _listBalita = data;
        });
      }
    });

    _bleService.isScanning.listen((scanning) {
      if (mounted) setState(() => _isScanning = scanning);
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
              _sensorWeight = w;
              _sensorHeight = h;
            });
          }
        }
      } catch (_) {}
    }

    if (_bleService.lastData != null) {
      processData(_bleService.lastData!);
    }

    _bleService.sensorDataStream.listen((rawData) {
      processData(rawData);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_autoConnectSheetShown &&
          _settingsService.settings.autoConnectBle &&
          !_isConnected &&
          mounted) {
        _autoConnectSheetShown = true;
        _showBleSelectionDialog();
      }
    });
  }

  String _formatDecimal(double val) {
    return val.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _initial(String? text, {String fallback = 'A'}) {
    final value = (text ?? '').trim();
    if (value.isEmpty) return fallback;
    return value[0].toUpperCase();
  }

  void _showEditProfileSheet(AppConfig config) {
    final nameCtrl = TextEditingController(text: config.adminName);
    final posyanduCtrl = TextEditingController(text: config.posyanduName);
    String? tempImagePath = config.adminPhoto;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'EDIT PROFIL ADMIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null)
                      setModalState(() => tempImagePath = image.path);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary, width: 3),
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          image: tempImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(tempImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: tempImagePath == null
                            ? const Icon(
                                Icons.person,
                                color: AppTheme.primary,
                                size: 42,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Admin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: posyanduCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Posyandu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    final newConfig = AppConfig(
                      adminName: nameCtrl.text,
                      posyanduName: posyanduCtrl.text,
                      adminPhoto: tempImagePath,
                    );
                    await IsarService().saveConfig(newConfig);
                    Navigator.pop(context);
                    ModernNotification.show(
                      context,
                      'Profil berhasil diperbarui!',
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN PERUBAHAN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (Keep existing BLE and notification methods)

  @override
  void dispose() {
    _bleService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
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
                    const SizedBox(height: 24),
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    _buildSensorIoTSection(),
                    const SizedBox(height: 24),
                    _buildRecentCheckupsSection(),
                  ],
                ),
              ),
            ),
            CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex == index) return;
                if (index == 1) {
                  Navigator.pushNamed(context, '/toddler_data');
                } else if (index == 2) {
                  Navigator.pushNamed(context, '/growth');
                } else if (index == 3) {
                  Navigator.pushNamed(context, '/export');
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
    return StreamBuilder<AppConfig?>(
      stream: IsarService().watchConfig(),
      builder: (context, snapshot) {
        final textPrimary = AppTheme.textPrimary(context);
        final config = snapshot.data;
        final String adminName = config?.adminName ?? 'Halo Admin';
        final String posyanduName =
            config?.posyanduName ?? 'Posyandu Kab. Pasuruan';
        final String? photoPath = config?.adminPhoto;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEditProfileSheet(
                    config ??
                        AppConfig(adminName: 'Admin', posyanduName: 'Pasuruan'),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary, width: 2),
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          image: photoPath != null && photoPath.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(File(photoPath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (photoPath == null || photoPath.isEmpty)
                            ? Text(
                                _initial(adminName),
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              posyanduName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadow(context),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      icon: const Icon(Icons.settings_outlined),
                      color: textPrimary,
                      tooltip: 'Settings',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadow(context),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/activity_logs');
                      },
                      icon: const Icon(Icons.history_rounded),
                      color: textPrimary,
                      tooltip: 'Aktivitas',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: _listBalita.any(
                      (b) => b.keterangan != 'Sehat',
                    ),
                    backgroundColor: Colors.red,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadow(context),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _showNotificationList,
                        icon: const Icon(Icons.notifications_outlined),
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- (Existing methods kept below) ---
  Widget _buildHeroSection() {
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Monitoring kesehatan balita hari ini',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorIoTSection() {
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);
    final Color accentColor = _isConnected
        ? AppTheme.primary
        : Colors.grey.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _isConnected
              ? AppTheme.surface(context)
              : AppTheme.surfaceMuted(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadow(context),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isConnected
                              ? 'Sensor Terhubung'
                              : (_isScanning
                                    ? 'Mencari Sensor...'
                                    : 'Sensor Offline'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isConnected
                                ? AppTheme.primary
                                : textPrimary,
                          ),
                        ),
                        Text(
                          _isScanning
                              ? 'Mendekatlah ke timbangan'
                              : _connectionStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isConnected
                        ? () {
                            _bleService.disconnect();
                            setState(() => _isConnected = false);
                          }
                        : (_isScanning
                              ? () => _bleService.stopScan()
                              : _showBleSelectionDialog),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _isConnected || _isScanning
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _isConnected
                            ? 'Putus'
                            : (_isScanning ? 'Batal' : 'Hubungkan'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isConnected || _isScanning
                              ? Colors.red
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isConnected) ...[
              Divider(
                height: 1,
                color: AppTheme.border(context),
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildMiniStat(
                      'Berat',
                      _formatDecimal(_sensorWeight),
                      'kg',
                      Icons.monitor_weight_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildMiniStat(
                      'Tinggi',
                      _formatDecimal(_sensorHeight),
                      'cm',
                      Icons.straighten_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? AppTheme.surfaceStrong(context).withValues(alpha: 0.4)
              : AppTheme.backgroundLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 18),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textSecondary,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCheckupsSection() {
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Checkup Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/toddler_data'),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_listBalita.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada data pemeriksaan',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            )
          else
            ..._listBalita.take(5).map((b) => _buildCheckupCard(b)).toList(),
        ],
      ),
    );
  }

  Widget _buildCheckupCard(Balita b) {
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);
    String statusLabel = b.displayStatus;

    Color statusColor = AppTheme.primary;
    if (statusLabel == 'Kurang Optimal')
      statusColor = AppTheme.statusDanger;
    else if (statusLabel == 'Berlebih')
      statusColor = AppTheme.statusWarning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            backgroundImage:
                (b.fotoProfile != null && b.fotoProfile!.isNotEmpty)
                ? FileImage(File(b.fotoProfile!))
                : null,
            child: (b.fotoProfile == null || b.fotoProfile!.isEmpty)
                ? Text(
                    _initial(b.nama, fallback: 'B'),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.nama ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '${b.usia} Bulan · ${b.berat}kg · ${b.tinggi}cm',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBleSelectionDialog() async {
    await _bleService.startScan();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppTheme.navBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PILIH PERANGKAT SENSOR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<bool>(
              stream: _bleService.isScanning,
              initialData: true,
              builder: (context, snapshot) => snapshot.data == true
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : const SizedBox(height: 32),
            ),
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: _bleService.scanResults,
                builder: (context, snapshot) {
                  final results = snapshot.data ?? [];
                  if (results.isEmpty)
                    return const Center(
                      child: Text(
                        'Tidak ada perangkat ditemukan',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = results[index];
                      return _buildBleDeviceItem(
                        r.device,
                        r.device.advName.isNotEmpty
                            ? r.device.advName
                            : 'Unknown Device',
                        r.rssi,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _bleService.stopScan();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StreamBuilder<bool>(
                      stream: _bleService.isScanning,
                      initialData: false,
                      builder: (context, snapshot) => FilledButton(
                        onPressed: (snapshot.data ?? false)
                            ? () => _bleService.stopScan()
                            : () => _bleService.startScan(),
                        style: FilledButton.styleFrom(
                          backgroundColor: (snapshot.data ?? false)
                              ? Colors.redAccent.withValues(alpha: 0.2)
                              : AppTheme.primary,
                          foregroundColor: (snapshot.data ?? false)
                              ? Colors.redAccent
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          (snapshot.data ?? false)
                              ? 'Berhenti Mencari'
                              : 'Pindai Ulang',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      _bleService.stopScan();
    });
  }

  Widget _buildBleDeviceItem(BluetoothDevice device, String name, int rssi) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        setState(() => _connectionStatus = 'Menghubungkan...');
        try {
          await _bleService.connectToDevice(device);
          if (mounted) {
            setState(() {
              _isConnected = true;
              _connectionStatus = 'Terhubung ke $name';
            });
            ModernNotification.show(context, 'Berhasil Terhubung');
          }
        } catch (e) {
          if (mounted) {
            setState(() => _connectionStatus = 'Gagal.');
            ModernNotification.show(context, 'Gagal terhubung.');
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bluetooth,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    device.remoteId.toString(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.signal_cellular_alt,
              color: rssi > -70 ? AppTheme.primary : Colors.orangeAccent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationList() {
    final List<Balita> highRiskBalita = _listBalita
        .where((b) => b.keterangan != 'Sehat')
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Health Alerts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${highRiskBalita.length} balita memerlukan perhatian',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: highRiskBalita.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              size: 64,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'All Clear!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No high-risk toddlers detected today.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: highRiskBalita.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildModernNotificationItem(highRiskBalita[index]),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNotificationItem(Balita b) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: Colors.orangeAccent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10, width: 2),
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          image: (b.fotoProfile != null &&
                                  b.fotoProfile!.isNotEmpty)
                              ? DecorationImage(
                                  image: FileImage(File(b.fotoProfile!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (b.fotoProfile == null || b.fotoProfile!.isEmpty)
                            ? Center(
                                child: Text(
                                  _initial(b.nama, fallback: 'B'),
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.nama ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${b.keterangan}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
