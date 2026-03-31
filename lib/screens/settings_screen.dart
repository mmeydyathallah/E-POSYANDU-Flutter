import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/activity_log_service.dart';
import '../services/app_settings_service.dart';
import '../services/isar_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_notification.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettingsService _settingsService = AppSettingsService();
  final ActivityLogService _logService = ActivityLogService();
  AppSettings _settings = AppSettings.defaults;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loaded = await _settingsService.load();
    await _logService.log('Settings', 'Membuka menu settings.');
    if (!mounted) return;
    setState(() {
      _settings = loaded;
      _loading = false;
    });
  }

  Future<void> _updateSettings(AppSettings next, String message) async {
    await _settingsService.save(next);
    await _logService.log('Settings', message);
    if (!mounted) return;
    setState(() => _settings = next);
  }

  Future<void> _showEditProfileSheet(AppConfig config) async {
    final nameCtrl = TextEditingController(text: config.adminName ?? '');
    final posyanduCtrl = TextEditingController(text: config.posyanduName ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Admin'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: posyanduCtrl,
                decoration: const InputDecoration(labelText: 'Nama Posyandu'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final updated = AppConfig(
                    adminName: nameCtrl.text.trim().isEmpty
                        ? 'Admin'
                        : nameCtrl.text.trim(),
                    posyanduName: posyanduCtrl.text.trim().isEmpty
                        ? 'Posyandu'
                        : posyanduCtrl.text.trim(),
                    adminPhoto: config.adminPhoto,
                  );
                  await IsarService().saveConfig(updated);
                  await _logService.log(
                    'Settings',
                    'Profil posyandu diperbarui dari menu settings.',
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ModernNotification.show(
                    context,
                    'Profil berhasil diperbarui.',
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/activity_logs'),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Lihat Aktivitas',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Profil Posyandu'),
          StreamBuilder<AppConfig?>(
            stream: IsarService().watchConfig(),
            builder: (context, snapshot) {
              final cfg = snapshot.data ??
                  AppConfig(adminName: 'Admin', posyanduName: 'Posyandu');
              return Card.outlined(
                child: ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(cfg.adminName ?? 'Admin'),
                  subtitle: Text(cfg.posyanduName ?? 'Posyandu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileSheet(cfg),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _sectionTitle('Pengaturan BLE'),
          SwitchListTile(
            value: _settings.autoConnectBle,
            onChanged: (v) {
              _updateSettings(
                _settings.copyWith(autoConnectBle: v),
                'Auto-connect BLE ${v ? "diaktifkan" : "dinonaktifkan"}.',
              );
            },
            title: const Text('Auto-connect perangkat BLE'),
            subtitle: const Text('Langsung coba konek saat perangkat ditemukan'),
          ),
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Scan timeout BLE'),
              subtitle: Text('${_settings.scanTimeoutSeconds} detik'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                int selected = _settings.scanTimeoutSeconds;
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pilih timeout scan'),
                    content: StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return DropdownButton<int>(
                          value: selected,
                          isExpanded: true,
                          items: const [10, 15, 20, 30, 45, 60]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('$s detik'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setStateDialog(() => selected = v);
                          },
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, selected),
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                );
                if (result == null) return;
                await _updateSettings(
                  _settings.copyWith(scanTimeoutSeconds: result),
                  'Timeout scan BLE diubah menjadi $result detik.',
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Pengukuran & Validasi'),
          SwitchListTile(
            value: _settings.confirmBeforeSave,
            onChanged: (v) {
              _updateSettings(
                _settings.copyWith(confirmBeforeSave: v),
                'Konfirmasi sebelum simpan ${v ? "diaktifkan" : "dinonaktifkan"}.',
              );
            },
            title: const Text('Konfirmasi sebelum simpan data'),
            subtitle: const Text('Mencegah salah simpan pengukuran'),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Tampilan & Bahasa'),
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Mode tampilan'),
              subtitle: Text(_settings.themeMode.toUpperCase()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final value = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Mode Tampilan'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'light'),
                        child: const Text('Light'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'dark'),
                        child: const Text('Dark'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'system'),
                        child: const Text('System'),
                      ),
                    ],
                  ),
                );
                if (value == null) return;
                await _updateSettings(
                  _settings.copyWith(themeMode: value),
                  'Mode tampilan diubah ke $value.',
                );
              },
            ),
          ),
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Bahasa'),
              subtitle: Text(_settings.language == 'id' ? 'Indonesia' : 'English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final value = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Bahasa'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'id'),
                        child: const Text('Indonesia'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'en'),
                        child: const Text('English'),
                      ),
                    ],
                  ),
                );
                if (value == null) return;
                await _updateSettings(
                  _settings.copyWith(language: value),
                  'Bahasa aplikasi diubah ke ${value == "id" ? "Indonesia" : "English"}.',
                );
              },
            ),
          ),
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.text_fields_outlined),
              title: const Text('Skala teks'),
              subtitle: Text('${_settings.textScale.toStringAsFixed(1)}x'),
            ),
          ),
          Slider(
            value: _settings.textScale,
            min: 0.9,
            max: 1.4,
            divisions: 5,
            label: '${_settings.textScale.toStringAsFixed(1)}x',
            onChanged: (v) {
              setState(() => _settings = _settings.copyWith(textScale: v));
            },
            onChangeEnd: (v) {
              _updateSettings(
                _settings.copyWith(textScale: v),
                'Skala teks diubah ke ${v.toStringAsFixed(1)}x.',
              );
            },
          ),
          const SizedBox(height: 16),
          _sectionTitle('Data & Backup'),
          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Riwayat Aktivitas Aplikasi'),
              subtitle: const Text('Lihat log aktivitas operasional'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/activity_logs'),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Tentang'),
          Card.outlined(
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('E-Posyandu'),
              subtitle: Text('Versi 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
