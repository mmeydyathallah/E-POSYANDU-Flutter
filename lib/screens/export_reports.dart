import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/activity_log_service.dart';
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
  final ActivityLogService _logService = ActivityLogService();

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
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      await _logService.log(
        'Export',
        'Ubah rentang laporan ke '
            '${picked.start.toIso8601String().substring(0, 10)} s/d '
            '${picked.end.toIso8601String().substring(0, 10)}.',
      );
    }
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
                  r.lingkarKepala != null
                      ? r.lingkarKepala!.toStringAsFixed(1)
                      : '-',
                  b.displayStatus,
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
                    'LK',
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
                    5: const pw.FixedColumnWidth(28),
                    6: const pw.FixedColumnWidth(28),
                    7: const pw.FixedColumnWidth(28),
                    8: const pw.FixedColumnWidth(48),
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
                    margin: const pw.EdgeInsets.only(top: 15),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      border: pw.Border.all(color: PdfColors.green300),
                      borderRadius: const pw.BorderRadius.vertical(
                        top: pw.Radius.circular(8),
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
                        pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Riwayat Perkembangan:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (b.riwayat == null || b.riwayat!.isEmpty) {
                  content.add(
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.vertical(
                          bottom: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Text(
                        'Belum ada riwayat terekam.',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ),
                  );
                } else {
                  content.add(
                    pw.TableHelper.fromTextArray(
                      headers: [
                        'Tanggal',
                        'Berat (kg)',
                        'Tinggi (cm)',
                        'LK (cm)',
                        'Status',
                      ],
                      data: b.riwayat!.map((r) => [
                        r.tanggal ?? '-',
                        (r.berat ?? 0.0).toStringAsFixed(1),
                        (r.tinggi ?? 0.0).toStringAsFixed(1),
                        r.lingkarKepala != null ? r.lingkarKepala!.toStringAsFixed(1) : '-',
                        b.displayStatus,
                      ]).toList(),
                      headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                      cellStyle: const pw.TextStyle(fontSize: 8),
                      cellHeight: 15,
                      border: pw.TableBorder.all(
                        color: PdfColors.grey400,
                        width: 0.5,
                      ),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                    ),
                  );
                }
                content.add(pw.SizedBox(height: 15));
              }
              return content;
            },
          ),
        );
      }
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      await _logService.log(
        'Export',
        'Export PDF berhasil (${_reportType == 0 ? "Kunjungan Harian" : "Master Balita"}).',
      );
      if (mounted) ModernNotification.show(context, 'PDF Berhasil Dibuat!');
    } catch (e) {
      await _logService.log('Export', 'Export PDF gagal: $e');
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

  // ── Helpers for Excel cell styles ─────────────────────────────────────────
  xl.CellStyle _xlHeader() => xl.CellStyle(
    backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
    fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
    bold: true,
    fontSize: 10,
    horizontalAlign: xl.HorizontalAlign.Center,
    verticalAlign: xl.VerticalAlign.Center,
    leftBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    rightBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    topBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    bottomBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
  );

  xl.CellStyle _xlData(bool isAlt) => xl.CellStyle(
    backgroundColorHex: isAlt
        ? xl.ExcelColor.fromHexString('#F5F5F5')
        : xl.ExcelColor.fromHexString('#FFFFFF'),
    fontSize: 9,
    leftBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    rightBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    topBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    bottomBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
  );

  xl.CellStyle _xlTitle() => xl.CellStyle(
    bold: true,
    fontSize: 14,
    fontColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
  );

  xl.CellStyle _xlSubHeader() => xl.CellStyle(
    bold: true,
    fontSize: 10,
    backgroundColorHex: xl.ExcelColor.fromHexString('#E8F5E9'),
    leftBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    rightBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    topBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
    bottomBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
  );

  void _xlCell(
    xl.Sheet sheet,
    int row,
    int col,
    String value,
    xl.CellStyle style,
  ) {
    final cell = sheet.cell(
      xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = xl.TextCellValue(value);
    cell.cellStyle = style;
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      final balitas = await IsarService().getAllBalita();
      final periodStr =
          '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year}'
          ' - '
          '${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}';

      final excel = xl.Excel.createExcel();
      excel.delete('Sheet1');

      if (_reportType == 0) {
        // ── Rekap Kunjungan Harian ─────────────────────────────────────────
        final sheet = excel['Kunjungan Harian'];

        // Merge title across 8 columns
        sheet.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          xl.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
        );
        final titleCell = sheet.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        );
        titleCell.value = xl.TextCellValue(
          'LAPORAN KUNJUNGAN HARIAN — SISTEM DIGITAL E-POSYANDU',
        );
        titleCell.cellStyle = _xlTitle();

        sheet.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
          xl.CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1),
        );
        final subCell = sheet.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        );
        subCell.value = xl.TextCellValue(
          'Puskesmas Kab. Pasuruan   |   Periode: $periodStr',
        );
        subCell.cellStyle = xl.CellStyle(
          fontSize: 9,
          fontColorHex: xl.ExcelColor.fromHexString('#555555'),
        );

        // Header row at row index 3
        const headers = [
          'No',
          'Tanggal',
          'Nama Balita',
          'JK',
          'Usia',
          'BB (kg)',
          'TB (cm)',
          'LK (cm)',
          'Status',
        ];
        for (int c = 0; c < headers.length; c++) {
          _xlCell(sheet, 3, c, headers[c], _xlHeader());
        }

        // Data rows
        int rowIdx = 4;
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
                final ds = _xlData(rowIdx.isOdd);
                final rowData = [
                  no.toString(),
                  r.tanggal!,
                  b.nama ?? '-',
                  b.jenisKelamin ?? '-',
                  '${b.usia ?? 0} Bln',
                  (r.berat ?? 0.0).toStringAsFixed(1),
                  (r.tinggi ?? 0.0).toStringAsFixed(1),
                  r.lingkarKepala != null ? r.lingkarKepala!.toStringAsFixed(1) : '-',
                  b.displayStatus,
                ];
                for (int c = 0; c < rowData.length; c++) {
                  _xlCell(sheet, rowIdx, c, rowData[c], ds);
                }
                rowIdx++;
                no++;
              }
            } catch (_) {}
          }
        }

        // Total row
        rowIdx++;
        final totalCell = sheet.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
        );
        totalCell.value = xl.TextCellValue('Total Data: ${no - 1} record');
        totalCell.cellStyle = xl.CellStyle(bold: true, fontSize: 9);

        // Column widths
        sheet.setColumnWidth(0, 6);
        sheet.setColumnWidth(1, 14);
        sheet.setColumnWidth(2, 28);
        sheet.setColumnWidth(3, 6);
        sheet.setColumnWidth(4, 10);
        sheet.setColumnWidth(5, 10);
        sheet.setColumnWidth(6, 10);
        sheet.setColumnWidth(7, 10);
        sheet.setColumnWidth(8, 18);
      } else {
        // ── Daftar Master Balita ───────────────────────────────────────────
        final sheet = excel['Daftar Master Balita'];

        sheet.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
        );
        final titleCell = sheet.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        );
        titleCell.value = xl.TextCellValue(
          'DAFTAR MASTER & REKAP BALITA — SISTEM DIGITAL E-POSYANDU',
        );
        titleCell.cellStyle = _xlTitle();

        sheet.merge(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
          xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1),
        );
        final subCell = sheet.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        );
        subCell.value = xl.TextCellValue(
          'Puskesmas Kab. Pasuruan   |   Periode: $periodStr',
        );
        subCell.cellStyle = xl.CellStyle(
          fontSize: 9,
          fontColorHex: xl.ExcelColor.fromHexString('#555555'),
        );

        int rowIdx = 3;

        for (var b in balitas) {
          // Name card header (full width, green background)
          sheet.merge(
            xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
            xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx),
          );
          final nameCell = sheet.cell(
            xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
          );
          nameCell.value = xl.TextCellValue((b.nama ?? '-').toUpperCase());
          nameCell.cellStyle = xl.CellStyle(
            backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
            fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
            bold: true,
            fontSize: 11,
          );
          rowIdx++;

          // Info row (light green background)
          final infoData = [
            'JK: ${b.jenisKelamin ?? "-"}',
            'Usia: ${b.usia ?? 0} Bln',
            'Ayah: ${b.namaAyah ?? "-"}',
            'Ibu: ${b.namaIbu ?? "-"}',
            'BB: ${(b.berat ?? 0.0).toStringAsFixed(1)} kg',
            'TB: ${(b.tinggi ?? 0.0).toStringAsFixed(1)} cm',
          ];
          for (int c = 0; c < infoData.length; c++) {
            final cell = sheet.cell(
              xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx),
            );
            cell.value = xl.TextCellValue(infoData[c]);
            cell.cellStyle = xl.CellStyle(
              fontSize: 9,
              backgroundColorHex: xl.ExcelColor.fromHexString('#E8F5E9'),
              leftBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
              rightBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
              topBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
              bottomBorder: xl.Border(borderStyle: xl.BorderStyle.Thin),
            );
          }
          rowIdx++;

          // History sub-table
          if (b.riwayat != null && b.riwayat!.isNotEmpty) {
            const subHeaders = [
              'Tanggal',
              'Berat (kg)',
              'Tinggi (cm)',
              'LK (cm)',
              'Status',
              '',
            ];
            for (int c = 0; c < subHeaders.length; c++) {
              if (subHeaders[c].isEmpty) continue;
              _xlCell(sheet, rowIdx, c, subHeaders[c], _xlSubHeader());
            }
            rowIdx++;

            for (int i = 0; i < b.riwayat!.length; i++) {
              final r = b.riwayat![i];
              final ds = _xlData(i.isOdd);
              final rd = [
                r.tanggal ?? '-',
                (r.berat ?? 0.0).toStringAsFixed(1),
                (r.tinggi ?? 0.0).toStringAsFixed(1),
                r.lingkarKepala != null
                    ? r.lingkarKepala!.toStringAsFixed(1)
                    : '-',
                b.displayStatus,
              ];
              for (int c = 0; c < rd.length; c++) {
                _xlCell(sheet, rowIdx, c, rd[c], ds);
              }
              rowIdx++;
            }
          } else {
            sheet.merge(
              xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
              xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx),
            );
            final na = sheet.cell(
              xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
            );
            na.value = xl.TextCellValue('Belum ada riwayat terekam.');
            na.cellStyle = xl.CellStyle(
              italic: true,
              fontSize: 9,
              fontColorHex: xl.ExcelColor.fromHexString('#888888'),
            );
            rowIdx++;
          }

          rowIdx++; // blank separator between balita
        }

        // Column widths
        sheet.setColumnWidth(0, 16);
        sheet.setColumnWidth(1, 12);
        sheet.setColumnWidth(2, 12);
        sheet.setColumnWidth(3, 18);
        sheet.setColumnWidth(4, 14);
        sheet.setColumnWidth(5, 14);
      }

      // Save & share
      final directory = await getTemporaryDirectory();
      final fileName =
          'rekap_posyandu_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      final bytes = excel.save();
      if (bytes == null) throw Exception('Gagal membuat file Excel');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Export Data Posyandu (.xlsx)');
      await _logService.log(
        'Export',
        'Export Excel berhasil (${_reportType == 0 ? "Kunjungan Harian" : "Master Balita"}).',
      );
      if (mounted)
        ModernNotification.show(context, 'Excel Berhasil Dibagikan!');
    } catch (e) {
      await _logService.log('Export', 'Export Excel gagal: $e');
      if (mounted) ModernNotification.show(context, 'Gagal ekspor Excel: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
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
                  Navigator.popUntil(context, ModalRoute.withName('/'));
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
    final textPrimary = AppTheme.textPrimary(context);

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
                color: textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Export & Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
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
    final textPrimary = AppTheme.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Card.outlined(
            margin: EdgeInsets.zero,
            color: AppTheme.surface(context),
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
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);

    return RadioListTile<int>(
      value: value,
      groupValue: _reportType,
      onChanged: (val) => setState(() => _reportType = val!),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        sub,
        style: TextStyle(fontSize: 11, color: textSecondary),
      ),
      secondary: Icon(
        icon,
        color: _reportType == value ? AppTheme.primary : Colors.grey,
      ),
      activeColor: AppTheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildExportActions() {
    final textPrimary = AppTheme.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unduh Laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
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
            onPressed: _isExporting ? null : _exportToExcel,
            icon: const Icon(Icons.table_view, color: AppTheme.primary),
            label: const Text('Ekspor ke Excel (.xlsx)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
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
    final textSecondary = AppTheme.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceMuted(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'File Excel (.xlsx) yang dihasilkan memiliki warna & format tabel yang identik dengan PDF. Buka dengan Microsoft Excel atau Google Sheets.',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
