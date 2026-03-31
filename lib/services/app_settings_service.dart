import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppSettings {
  final bool autoConnectBle;
  final int scanTimeoutSeconds;
  final bool confirmBeforeSave;
  final String themeMode;
  final String language;
  final double textScale;

  const AppSettings({
    required this.autoConnectBle,
    required this.scanTimeoutSeconds,
    required this.confirmBeforeSave,
    required this.themeMode,
    required this.language,
    required this.textScale,
  });

  static const AppSettings defaults = AppSettings(
    autoConnectBle: false,
    scanTimeoutSeconds: 15,
    confirmBeforeSave: true,
    themeMode: 'light',
    language: 'id',
    textScale: 1.0,
  );

  AppSettings copyWith({
    bool? autoConnectBle,
    int? scanTimeoutSeconds,
    bool? confirmBeforeSave,
    String? themeMode,
    String? language,
    double? textScale,
  }) {
    return AppSettings(
      autoConnectBle: autoConnectBle ?? this.autoConnectBle,
      scanTimeoutSeconds: scanTimeoutSeconds ?? this.scanTimeoutSeconds,
      confirmBeforeSave: confirmBeforeSave ?? this.confirmBeforeSave,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      textScale: textScale ?? this.textScale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoConnectBle': autoConnectBle,
      'scanTimeoutSeconds': scanTimeoutSeconds,
      'confirmBeforeSave': confirmBeforeSave,
      'themeMode': themeMode,
      'language': language,
      'textScale': textScale,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      autoConnectBle: json['autoConnectBle'] == true,
      scanTimeoutSeconds: (json['scanTimeoutSeconds'] as num?)?.toInt() ?? 15,
      confirmBeforeSave: json['confirmBeforeSave'] != false,
      themeMode: (json['themeMode'] as String?) ?? 'light',
      language: (json['language'] as String?) ?? 'id',
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService _instance = AppSettingsService._();
  factory AppSettingsService() => _instance;

  AppSettings _settings = AppSettings.defaults;
  final ValueNotifier<AppSettings> _notifier =
      ValueNotifier<AppSettings>(AppSettings.defaults);

  AppSettings get settings => _settings;
  ValueListenable<AppSettings> get listen => _notifier;

  Future<File> _settingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/app_settings.json');
  }

  Future<AppSettings> load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) return _settings;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return _settings;
      _settings = AppSettings.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      _notifier.value = _settings;
      return _settings;
    } catch (_) {
      return _settings;
    }
  }

  Future<void> save(AppSettings next) async {
    _settings = next;
    _notifier.value = next;
    try {
      final file = await _settingsFile();
      await file.writeAsString(jsonEncode(next.toJson()), flush: true);
    } catch (_) {}
  }
}
