import 'package:flutter/material.dart';

import '../services/activity_log_service.dart';
import '../theme/app_theme.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  final ActivityLogService _logService = ActivityLogService();

  @override
  void initState() {
    super.initState();
    _logService.init();
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua log?'),
        content: const Text('Seluruh riwayat aktivitas akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _logService.clear();
  }

  String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Aktivitas Aplikasi'),
        actions: [
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: StreamBuilder<List<ActivityLogEntry>>(
        stream: _logService.stream,
        initialData: _logService.entries,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada aktivitas tercatat.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card.outlined(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(
                    log.message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${log.category} - ${_fmt(log.timestamp)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

