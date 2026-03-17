import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/models.dart';
import '../services/isar_service.dart';
import '../widgets/modern_notification.dart';

class ExportReportsScreen extends StatefulWidget {
  const ExportReportsScreen({Key? key}) : super(key: key);

  @override
  State<ExportReportsScreen> createState() => _ExportReportsScreenState();
}

class _ExportReportsScreenState extends State<ExportReportsScreen> {
  int _currentIndex = 3;
  DateTimeRange? _selectedDateRange;
  bool _isExporting = false;
  int _reportType = 0;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  Future<void> _exportToPDF() async {
    setState(() => _isExporting = true);
    try {
      final balitas = await IsarService().getAllBalita();
      final pdf = pw.Document();

      if (_reportType == 0) {
        List<List<String>> tableData = [];
        int no = 1;
        for (var b in balitas) {
          if (b.riwayat == null) continue;
          for (var r in b.riwayat!) {
            if (r.tanggal == null) continue;
            try {
              DateTime dt = DateTime.parse(r.tanggal!);
              DateTime checkDate = DateTime(dt.year, dt.month, dt.day);
              DateTime startDate = DateTime(
                _selectedDateRange!.start.year,
                _selectedDateRange!.start.month,
                _selectedDateRange!.start.day,
              );
              DateTime endDate = DateTime(
                _selectedDateRange!.end.year,
                _selectedDateRange!.end.month,
                _selectedDateRange!.end.day,
              );

              if ((checkDate.isAfter(startDate) ||
                      checkDate.isAtSameMomentAs(startDate)) &&
                  (checkDate.isBefore(endDate) ||
                      checkDate.isAtSameMomentAs(endDate))) {
                tableData.add([
                  no.toString(),
                  r.tanggal!,
                  b.nama ?? '-',
                  b.jenisKelamin ?? '-',
                  '${b.usia ?? 0} Bln',
                  (r.berat ?? 0.0).toStringAsFixed(1),
                  (r.tinggi ?? 0.0).toStringAsFixed(1),
                  b.keterangan ?? '-',
                ]);
                no++;
              }
            } catch (_) {}
          }
        }
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            header: (context) => _buildPdfHeader('LAPORAN KUNJUNGAN HARIAN'),
            footer: (context) => _buildPdfFooter(),
            build: (context) => [
              pw.SizedBox(height: 10),
              if (tableData.isEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Text('Tidak ada data pada rentang ini.'),
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: [
                    'No',
                    'Tanggal',
                    'Nama Balita',
                    'JK',
                    'Usia',
                    'BB',
                    'TB',
                    'Status',
                  ],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 8,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.green800,
                  ),
                  data: tableData,
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(20),
                    1: const pw.FixedColumnWidth(55),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FixedColumnWidth(25),
                    4: const pw.FixedColumnWidth(35),
                    5: const pw.FixedColumnWidth(30),
                    6: const pw.FixedColumnWidth(30),
                    7: const pw.FixedColumnWidth(55),
                  },
                ),
            ],
          ),
        );
      } else {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            header: (context) =>
                _buildPdfHeader('DAFTAR MASTER & REKAP BALITA'),
            footer: (context) => _buildPdfFooter(),
            build: (context) {
              List<pw.Widget> content = [];
              for (var b in balitas) {
                content.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              b.nama?.toUpperCase() ?? '-',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.green900,
                              ),
                            ),
                            pw.Text(
                              'JK: ${b.jenisKelamin} | Usia: ${b.usia} Bln',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Orang Tua: ${b.namaAyah ?? "-"} (Ayah), ${b.namaIbu ?? "-"} (Ibu)',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Divider(thickness: 0.5, color: PdfColors.grey200),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Riwayat Perkembangan:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        if (b.riwayat == null || b.riwayat!.isEmpty)
                          pw.Text(
                            'Belum ada riwayat terekam.',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey500,
                            ),
                          )
                        else
                          pw.TableHelper.fromTextArray(
                            headers: [
                              'Tanggal',
                              'Berat (kg)',
                              'Tinggi (cm)',
                              'Status',
                            ],
                            data: b.riwayat!
                                .map(
                                  (r) => [
                                    r.tanggal ?? '-',
                                    (r.berat ?? 0.0).toStringAsFixed(1),
                                    (r.tinggi ?? 0.0).toStringAsFixed(1),
                                    b.keterangan ?? '-',
                                  ],
                                )
                                .toList(),
                            headerStyle: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                            cellStyle: const pw.TextStyle(fontSize: 8),
                            cellHeight: 15,
                            border: null,
                            headerDecoration: const pw.BoxDecoration(
                              color: PdfColors.grey100,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return content;
            },
          ),
        );
      }
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      if (mounted) ModernNotification.show(context, 'PDF Berhasil Dibuat!');
    } catch (e) {
      if (mounted) ModernNotification.show(context, 'Gagal ekspor PDF: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  pw.Widget _buildPdfHeader(String title) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: PdfColors.green900,
                  ),
                ),
                pw.Text(
                  'SISTEM DIGITAL E-POSYANDU',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Puskesmas Kab. Pasuruan',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.Text(
                  'Periode: ${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  'Dicetak pada: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Container(width: 120, height: 0.5, color: PdfColors.black),
                pw.Text(
                  'Admin Posyandu',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);
    try {
      final balitas = await IsarService().getAllBalita();
      List<List<dynamic>> rows = [
        ['REKAPITULASI DATA POSYANDU DIGITAL'],
        [
          'Periode',
          '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
        ],
        [
          'Tipe Laporan',
          _reportType == 0 ? 'Kunjungan Harian' : 'Daftar Master Balita',
        ],
        [],
        [
          'No',
          'Tanggal',
          'Nama Balita',
          'JK',
          'Usia (Bulan)',
          'Berat (kg)',
          'Tinggi (cm)',
          'Status',
        ],
      ];
      if (_reportType == 0) {
        int no = 1;
        for (var b in balitas) {
          if (b.riwayat == null) continue;
          for (var r in b.riwayat!) {
            if (r.tanggal == null) continue;
            try {
              DateTime dt = DateTime.parse(r.tanggal!);
              if (dt.isAfter(
                    _selectedDateRange!.start.subtract(const Duration(days: 1)),
                  ) &&
                  dt.isBefore(
                    _selectedDateRange!.end.add(const Duration(days: 1)),
                  )) {
                rows.add([
                  no,
                  r.tanggal!,
                  b.nama ?? '-',
                  b.jenisKelamin ?? '-',
                  b.usia ?? 0,
                  r.berat ?? 0.0,
                  r.tinggi ?? 0.0,
                  b.keterangan ?? '-',
                ]);
                no++;
              }
            } catch (_) {}
          }
        }
      } else {
        int no = 1;
        for (var b in balitas) {
          rows.add([
            no,
            b.tanggalDaftar ?? '-',
            b.nama ?? '-',
            b.jenisKelamin ?? '-',
            b.usia ?? 0,
            b.berat ?? 0.0,
            b.tinggi ?? 0.0,
            b.keterangan ?? '-',
          ]);
          if (b.riwayat != null)
            for (var r in b.riwayat!)
              rows.add([
                '',
                '-> ${r.tanggal}',
                'Rekap',
                '',
                '',
                r.berat,
                r.tinggi,
                '',
              ]);
          no++;
        }
      }
      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final file = File(
        "${directory.path}/rekap_posyandu_${DateTime.now().millisecondsSinceEpoch}.csv",
      );
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], text: 'Export Data Posyandu');
      if (mounted) ModernNotification.show(context, 'CSV Berhasil Dibagikan!');
    } catch (e) {
      if (mounted) ModernNotification.show(context, 'Gagal ekspor CSV: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SizedBox.expand(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDateRangeSelector(),
                    const SizedBox(height: 24),
                    _buildReportTypeSelection(),
                    const SizedBox(height: 24),
                    _buildExportActions(),
                    const SizedBox(height: 24),
                    _buildQuickTips(),
                  ],
                ),
              ),
            ),
            CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex == index) return;
                setState(() => _currentIndex = index);
                if (index == 0)
                  Navigator.pushReplacementNamed(context, '/');
                else if (index == 1)
                  Navigator.pushReplacementNamed(context, '/toddler_data');
                else if (index == 2)
                  Navigator.pushReplacementNamed(context, '/growth');
              },
              onAddTap: () => Navigator.pushNamed(context, '/input'),
            ),
            if (_isExporting)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
                color: Colors.black87,
              ),
              const SizedBox(width: 8),
              const Text(
                'Export & Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Icon(Icons.description_outlined, color: AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final start = _selectedDateRange?.start;
    final end = _selectedDateRange?.end;
    final dateStr = start != null && end != null
        ? "${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}"
        : "Pilih Rentang Tanggal";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rentang Tanggal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _selectDateRange,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 16),
                Text(
                  dateStr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.edit, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipe Laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Card.outlined(
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildTypeOption(
                  0,
                  'Rekap Kunjungan Harian',
                  'Data pemeriksaan terperinci di rentang tanggal',
                  Icons.history_rounded,
                ),
                const Divider(height: 1),
                _buildTypeOption(
                  1,
                  'Daftar Master Balita',
                  'Profil lengkap balita beserta seluruh riwayatnya',
                  Icons.people_alt_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(int value, String title, String sub, IconData icon) {
    return RadioListTile<int>(
      value: value,
      groupValue: _reportType,
      onChanged: (val) => setState(() => _reportType = val!),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
      secondary: Icon(
        icon,
        color: _reportType == value ? AppTheme.primary : Colors.grey,
      ),
      activeColor: AppTheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildExportActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unduh Laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          FilledButton.icon(
            onPressed: _isExporting ? null : _exportToPDF,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Ekspor ke PDF'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportToCSV,
            icon: const Icon(Icons.table_view, color: AppTheme.primary),
            label: const Text('Ekspor ke CSV (Excel)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tipe "Daftar Master Balita" akan menampilkan seluruh riwayat pemeriksaan per anak untuk arsip lengkap.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
