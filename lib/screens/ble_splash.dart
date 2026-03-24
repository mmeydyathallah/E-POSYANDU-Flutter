import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../theme/app_theme.dart';
import '../services/ble_service.dart';

class BLEDiceSplashScreen extends StatefulWidget {
  const BLEDiceSplashScreen({super.key});

  @override
  State<BLEDiceSplashScreen> createState() => _BLEDiceSplashScreenState();
}

class _BLEDiceSplashScreenState extends State<BLEDiceSplashScreen> {
  final BleService _bleService = BleService();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _bleService.startScan();
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _isConnecting = true);
    try {
      await _bleService.connectToDevice(device);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/input_data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal terhubung: $e')));
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Decorative background
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Expanded(child: _buildMainCard()),
                        const SizedBox(height: 24),
                        _buildBottomAction(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isConnecting)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'E-POSYANDU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'DIGITAL HEALTH ASSISTANT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Card.outlined(
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hubungkan Perangkat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder<bool>(
              stream: _bleService.isScanning,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Text(
                    'Mencari perangkat di sekitar...',
                    style: TextStyle(fontSize: 14, color: AppTheme.primary),
                  );
                }
                return const Text(
                  'Siap untuk memindai perangkat.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: _bleService.scanResults,
                builder: (context, snapshot) {
                  final results = snapshot.data ?? [];
                  // Filter hanya perangkat eposyandu (atau tampilkan semua jika ingin)
                  final filteredResults = results.where((r) {
                    final name = r.advertisementData.advName;
                    return name.toLowerCase().contains('eposyandu');
                  }).toList();

                  if (filteredResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada perangkat ditemukan',
                            style: TextStyle(color: Colors.black38),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredResults.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = filteredResults[index];
                      return _buildDeviceItem(r);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(ScanResult result) {
    final name = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : "Unknown Device";
    final rssi = result.rssi;

    IconData signalIcon = Icons.signal_cellular_alt;
    Color signalColor = AppTheme.primary;
    String signalText = "Excellent Signal";

    if (rssi < -80) {
      signalIcon = Icons.signal_cellular_alt_1_bar;
      signalColor = Colors.grey;
      signalText = "Weak Signal";
    } else if (rssi < -60) {
      signalIcon = Icons.signal_cellular_alt_2_bar;
      signalColor = Colors.orange;
      signalText = "Good Signal";
    }

    return Card.outlined(
      margin: EdgeInsets.zero,
      color: Colors.grey.shade50.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                color: AppTheme.primary,
                size: 24,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(signalIcon, size: 12, color: signalColor),
                      const SizedBox(width: 4),
                      Text(
                        signalText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: signalColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => _connect(result.device),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Column(
      children: [
        StreamBuilder<bool>(
          stream: _bleService.isScanning,
          initialData: false,
          builder: (context, snapshot) {
            final isScanning = snapshot.data == true;
            return OutlinedButton.icon(
              onPressed: isScanning ? null : _startScan,
              icon: isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(isScanning ? 'Memindai...' : 'Cari Perangkat Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Pastikan perangkat menyala dan Bluetooth aktif.\nApp Version 2.4.0',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.black45, height: 1.5),
        ),
      ],
    );
  }
}
