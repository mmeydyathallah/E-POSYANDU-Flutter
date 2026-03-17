import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.navBackground.withValues(
            alpha: 0.9,
          ), // Glassmorphism background
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.dataset_rounded, 'Data'),
            // Add/Input button aligned with other icons
            GestureDetector(
              onTap: onAddTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppTheme.navBackground,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Input',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildNavItem(2, Icons.trending_up_rounded, 'Growth'),
            _buildNavItem(3, Icons.ios_share_rounded, 'Export'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primary : Colors.grey.shade500,
            size: 28,
            shadows: isSelected
                ? [
                    Shadow(
                      color: AppTheme.primary.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
