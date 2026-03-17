import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/models.dart';
import '../services/isar_service.dart';
import 'toddler_detail.dart';

class ToddlerDataScreen extends StatefulWidget {
  const ToddlerDataScreen({Key? key}) : super(key: key);

  @override
  State<ToddlerDataScreen> createState() => _ToddlerDataScreenState();
}

class _ToddlerDataScreenState extends State<ToddlerDataScreen> {
  int _currentIndex = 1;
  List<Balita> _listBalita = [];

  @override
  void initState() {
    super.initState();
    IsarService().watchAllBalita().listen((data) {
      if (mounted) {
        setState(() {
          _listBalita = data;
        });
      }
    });
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
                  AppBar(
                    title: const Text('Data Balita'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Badge(
                          isLabelVisible:
                              false, // Can be connected to state later
                          child: IconButton(
                            onPressed: () {}, // Show notification list?
                            icon: const Icon(Icons.notifications_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildSearchBar(),
                  _buildFilters(),
                  Expanded(child: _buildToddlerList()),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
            CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex == index) return;

                setState(() => _currentIndex = index);

                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case 1:
                    // Already on Toddler Data
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/growth');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/export');
                    break;
                }
              },
              onAddTap: () {
                Navigator.pushNamed(context, '/input');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SearchBar(
        hintText: 'Cari nama balita...',
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        leading: const Icon(Icons.search, color: AppTheme.primary),
        elevation: const WidgetStatePropertyAll<double>(0),
        backgroundColor: WidgetStatePropertyAll<Color>(
          Colors.white.withValues(alpha: 0.8),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onChanged: (value) {
          // Implement search logic here
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Semua'),
              selected: true,
              onSelected: (val) {},
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Terbaru'),
              selected: false,
              onSelected: (val) {},
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Risiko Tinggi'),
              selected: false,
              onSelected: (val) {},
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToddlerList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Registered Toddlers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_listBalita.length} Total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _listBalita.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data balita. Silakan tambahkan!',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: _listBalita
                        .map(
                          (balita) => Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ToddlerDetailScreen(balita: balita),
                                    ),
                                  );
                                },
                                child: _buildToddlerItem(
                                  name: balita.nama ?? 'Nama Anak',
                                  details:
                                      '${balita.usia ?? 0} Bulan • ID: ${(balita.tanggalDaftar ?? '').isNotEmpty ? (balita.tanggalDaftar ?? '').substring(0, 4) : "0000"}',
                                  status: balita.keterangan ?? '-',
                                  statusColor: balita.keterangan == 'Sehat'
                                      ? AppTheme.primary
                                      : Colors.orange,
                                  imageUrl:
                                      'https://mighty.tools/mockmind-api/content/human/${((balita.nama ?? '').length % 50) + 10}.jpg',
                                  localPhotoPath: balita.fotoProfile,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToddlerItem({
    required String name,
    required String details,
    required String status,
    required Color statusColor,
    required String imageUrl,
    String? localPhotoPath,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isWarning
            ? Border(left: BorderSide(color: statusColor, width: 4))
            : Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                  image: DecorationImage(
                    image: (localPhotoPath != null && localPhotoPath.isNotEmpty)
                        ? FileImage(File(localPhotoPath))
                        : NetworkImage(imageUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
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
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isWarning ? Colors.black38 : AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
