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
  String _selectedFilter = 'Semua';

  String _initial(String? text, {String fallback = 'B'}) {
    final value = (text ?? '').trim();
    if (value.isEmpty) return fallback;
    return value[0].toUpperCase();
  }

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
    final textPrimary = AppTheme.textPrimary(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: SizedBox.expand(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      'Data Balita',
                      style: TextStyle(color: textPrimary),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () =>
                          Navigator.popUntil(context, ModalRoute.withName('/')),
                      icon: const Icon(Icons.arrow_back),
                    ),
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
                if (index == 0) {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/growth');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/export');
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
    final textPrimary = AppTheme.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Semua'),
              selected: _selectedFilter == 'Semua',
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = 'Semua');
              },
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                fontWeight: _selectedFilter == 'Semua'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedFilter == 'Semua'
                    ? AppTheme.primary
                    : textPrimary,
              ),
              side: BorderSide(
                color: _selectedFilter == 'Semua'
                    ? Colors.transparent
                    : AppTheme.border(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Terbaru'),
              selected: _selectedFilter == 'Terbaru',
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = 'Terbaru');
              },
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                fontWeight: _selectedFilter == 'Terbaru'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedFilter == 'Terbaru'
                    ? AppTheme.primary
                    : textPrimary,
              ),
              side: BorderSide(
                color: _selectedFilter == 'Terbaru'
                    ? Colors.transparent
                    : AppTheme.border(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Risiko Tinggi'),
              selected: _selectedFilter == 'Risiko Tinggi',
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = 'Risiko Tinggi');
              },
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                fontWeight: _selectedFilter == 'Risiko Tinggi'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedFilter == 'Risiko Tinggi'
                    ? AppTheme.primary
                    : textPrimary,
              ),
              side: BorderSide(
                color: _selectedFilter == 'Risiko Tinggi'
                    ? Colors.transparent
                    : AppTheme.border(context),
              ),
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
    final textSecondary = AppTheme.textSecondary(context);

    List<Balita> filteredList = _listBalita;
    if (_selectedFilter == 'Terbaru') {
      filteredList = List.from(_listBalita)
        ..sort((a, b) => b.id.compareTo(a.id));
    } else if (_selectedFilter == 'Risiko Tinggi') {
      filteredList = _listBalita
          .where(
            (b) =>
                b.keterangan != 'Sehat' &&
                b.keterangan != null &&
                b.keterangan!.isNotEmpty,
          )
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Registered Toddlers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              Text(
                '${filteredList.length} Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data balita. Silakan tambahkan!',
                      style: TextStyle(color: textSecondary),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: filteredList
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
                                  status: balita.displayStatus,
                                  statusColor: balita.displayStatus == 'Optimal'
                                      ? AppTheme.primary
                                      : (balita.displayStatus == 'Berlebih'
                                            ? AppTheme.statusWarning
                                            : AppTheme.statusDanger),
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
    String? localPhotoPath,
    bool isWarning = false,
  }) {
    final isDark = AppTheme.isDark(context);
    final textSecondary = AppTheme.textSecondary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: isWarning
            ? Border(left: BorderSide(color: statusColor, width: 4))
            : Border.all(color: AppTheme.border(context)),
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
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadow(context),
                      blurRadius: 4,
                    ),
                  ],
                  image: (localPhotoPath != null && localPhotoPath.isNotEmpty)
                      ? DecorationImage(
                          image: FileImage(File(localPhotoPath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (localPhotoPath == null || localPhotoPath.isEmpty)
                    ? Center(
                        child: Text(
                          _initial(name),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      )
                    : null,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
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
            color: isWarning ? AppTheme.textTertiary(context) : AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
