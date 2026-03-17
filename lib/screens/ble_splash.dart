import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BLEDiceSplashScreen extends StatelessWidget {
  const BLEDiceSplashScreen({Key? key}) : super(key: key);

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildMainCard(),
                        const SizedBox(height: 32),
                        _buildBottomAction(),
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
              'Connect to Device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Searching for measurement devices nearby...',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildDeviceItem(
              'Smart Scale V2',
              Icons.monitor_weight_outlined,
              'Excellent Signal',
              Icons.signal_cellular_alt,
              AppTheme.primary,
            ),
            const SizedBox(height: 12),
            _buildDeviceItem(
              'Stadiometer Pro',
              Icons.straighten_outlined,
              'Good Signal',
              Icons.signal_cellular_alt_2_bar,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildDeviceItem(
              'Baby Scale X1',
              Icons.child_care_outlined,
              'Weak Signal',
              Icons.signal_cellular_alt_1_bar,
              Colors.grey.shade400,
            ),
            const SizedBox(height: 32),
            _buildIllustration(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    String name,
    IconData icon,
    String signalText,
    IconData signalIcon,
    Color signalColor,
  ) {
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
              child: Icon(icon, color: AppTheme.primary, size: 24),
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
              onPressed: () {},
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

  Widget _buildIllustration() {
    return Center(
      child: SizedBox(
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bluetooth, color: AppTheme.primary, size: 48),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      width: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          label: const Text('Rescan for Devices'),
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
        ),
        const SizedBox(height: 24),
        const Text(
          'Ensure your device is turned on and Bluetooth is enabled.\nApp Version 2.4.0',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.black45, height: 1.5),
        ),
      ],
    );
  }
}
