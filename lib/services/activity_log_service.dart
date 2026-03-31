import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ActivityLogEntry {
  final DateTime timestamp;
  final String category;
  final String message;

  const ActivityLogEntry({
    required this.timestamp,
    required this.category,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'message': message,
    };
  }

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      category: (json['category'] as String? ?? 'System').trim(),
      message: (json['message'] as String? ?? '').trim(),
    );
  }
}

class ActivityLogService {
  ActivityLogService._();
  static final ActivityLogService _instance = ActivityLogService._();
  factory ActivityLogService() => _instance;

  static const int _maxEntries = 500;
  final List<ActivityLogEntry> _entries = [];
  final StreamController<List<ActivityLogEntry>> _controller =
      StreamController<List<ActivityLogEntry>>.broadcast();
  bool _initialized = false;

  Stream<List<ActivityLogEntry>> get stream => _controller.stream;
  List<ActivityLogEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromDisk();
    _controller.add(entries);
  }

  Future<File> _logFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/activity_logs.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _logFile();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return;
      final parsed = jsonDecode(raw);
      if (parsed is! List) return;

      _entries
        ..clear()
        ..addAll(
          parsed
              .whereType<Map>()
              .map((e) => ActivityLogEntry.fromJson(
                    Map<String, dynamic>.from(e),
                  )),
        );
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (_entries.length > _maxEntries) {
        _entries.removeRange(_maxEntries, _entries.length);
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final file = await _logFile();
      final payload = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await file.writeAsString(payload, flush: true);
    } catch (_) {}
  }

  Future<void> log(String category, String message) async {
    if (!_initialized) await init();
    final entry = ActivityLogEntry(
      timestamp: DateTime.now(),
      category: category.trim().isEmpty ? 'System' : category.trim(),
      message: message.trim(),
    );
    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeLast();
    }
    _controller.add(entries);
    await _persist();
  }

  Future<void> clear() async {
    _entries.clear();
    _controller.add(entries);
    await _persist();
  }
}

