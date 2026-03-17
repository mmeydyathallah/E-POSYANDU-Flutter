import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/isar_service.dart';
import 'register_toddler.dart';
import '../widgets/modern_notification.dart';

class ToddlerDetailScreen extends StatefulWidget {
  final Balita balita;

  const ToddlerDetailScreen({Key? key, required this.balita}) : super(key: key);

  @override
  State<ToddlerDetailScreen> createState() => _ToddlerDetailScreenState();
}

class _ToddlerDetailScreenState extends State<ToddlerDetailScreen> {
  late Balita _currentBalita;

  @override
  void initState() {
    super.initState();
    _currentBalita = widget.balita;
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RegisterToddlerScreen(balitaToEdit: _currentBalita),
      ),
    );

    if (result == true) {
      final all = await IsarService().getAllBalita();
      final updated = all.firstWhere((b) => b.id == _currentBalita.id);
      setState(() {
        _currentBalita = updated;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Balita?'),
        content: Text(
          'Seluruh data riwayat ${_currentBalita.nama} juga akan terhapus secara permanen.',
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await IsarService().deleteBalita(_currentBalita.id);
      if (mounted) {
        ModernNotification.show(
          context,
          'Data ${_currentBalita.nama} telah dihapus.',
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSehat = _currentBalita.keterangan == 'Sehat';
    final Color statusColor = isSehat
        ? AppTheme.primary
        : AppTheme.statusWarning;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        'Profil Balita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton.filled(
                            onPressed: _navigateToEdit,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _confirmDelete,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    backgroundImage:
                        (_currentBalita.fotoProfile != null &&
                            _currentBalita.fotoProfile!.isNotEmpty)
                        ? FileImage(File(_currentBalita.fotoProfile!))
                        : null,
                    child:
                        (_currentBalita.fotoProfile == null ||
                            _currentBalita.fotoProfile!.isEmpty)
                        ? Text(
                            (_currentBalita.nama?.isNotEmpty ?? false)
                                ? _currentBalita.nama![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentBalita.nama ?? 'Anak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentBalita.jenisKelamin == 'L'
                        ? '♂ Laki-laki'
                        : '♀ Perempuan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildCard(
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.cake_outlined,
                                'Usia',
                                '${_currentBalita.usia} Bulan',
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                Icons.monitor_weight_outlined,
                                'Berat Badan',
                                '${_currentBalita.berat} kg',
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                Icons.straighten_outlined,
                                'Tinggi Badan',
                                '${_currentBalita.tinggi} cm',
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                Icons.radio_button_checked,
                                'Lingkar Kepala',
                                '${_currentBalita.lingkarKepala} cm',
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Icon(
                                    Icons.health_and_safety_outlined,
                                    color: statusColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Keterangan',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      (_currentBalita.keterangan ?? '-')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Orang Tua',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.man_outlined,
                                'Nama Ayah',
                                _currentBalita.namaAyah ?? '-',
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                Icons.woman_outlined,
                                'Nama Ibu',
                                _currentBalita.namaIbu ?? '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCard(
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.event_outlined,
                                'Tanggal Lahir',
                                _currentBalita.tanggalLahir ?? '-',
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                Icons.app_registration_outlined,
                                'Tanggal Daftar',
                                _currentBalita.tanggalDaftar ?? '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
