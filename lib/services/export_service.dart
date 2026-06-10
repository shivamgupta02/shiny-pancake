import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/category.dart';
import '../data/models/expense.dart';

class ExportService {
  Future<String> generateExcel(
    List<Expense> expenses,
    List<Category> categories,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Expenses');
    final sheet = excel['Expenses'];

    // Header row (bold)
    final headerStyle = CellStyle(
      bold: true,
    );

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Amount (₹)'),
      TextCellValue('Category'),
      TextCellValue('Description'),
    ]);

    // Apply bold style to header cells
    for (var col = 0; col < 4; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = headerStyle;
    }

    // Build category map
    final categoryMap = <String, String>{};
    for (final cat in categories) {
      categoryMap[cat.uid] = cat.name;
    }

    // Sort expenses by date ascending
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Data rows
    double total = 0;
    for (final expense in sortedExpenses) {
      final categoryName = categoryMap[expense.categoryId] ?? 'Unknown';
      sheet.appendRow([
        TextCellValue(DateFormatter.formatForExport(expense.date)),
        DoubleCellValue(expense.amount),
        TextCellValue(categoryName),
        TextCellValue(expense.description ?? ''),
      ]);
      total += expense.amount;
    }

    // Summary row
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue('Total: ${CurrencyFormatter.format(total)}'),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    // Apply bold to summary row
    final summaryRowIndex = sortedExpenses.length + 1;
    sheet
        .cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: summaryRowIndex))
        .cellStyle = CellStyle(bold: true);

    // Save file
    final dir = await getTemporaryDirectory();
    final fromStr = DateFormatter.formatForExport(dateFrom);
    final toStr = DateFormatter.formatForExport(dateTo);
    final fileName = 'expenses_${fromStr}_$toStr.xlsx';
    final filePath = '${dir.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    return filePath;
  }

  Future<String> generatePdf({
    required double totalSpent,
    required double averageDaily,
    required double percentageChange,
    required bool isFirstMonth,
    required List<({String name, double amount, double percentage})>
        categoryBreakdown,
    required DateTime month,
  }) async {
    final pdf = pw.Document();
    final monthYear = DateFormatter.formatMonthYear(month);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'EXPENSE REPORT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  monthYear,
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Summary section
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildSummaryRow(
                'Total Spent',
                CurrencyFormatter.format(totalSpent),
              ),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                'Average Daily',
                CurrencyFormatter.format(averageDaily),
              ),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                'vs Previous Month',
                _formatPercentageChange(percentageChange, isFirstMonth),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Category breakdown
              pw.Text(
                'Category Breakdown',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildCategoryTable(categoryBreakdown),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated on ${DateFormatter.formatFull(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save file
    final dir = await getTemporaryDirectory();
    final monthStr = DateFormat('MMMM').format(month).toLowerCase();
    final year = month.year;
    final fileName = 'report_${monthStr}_$year.pdf';
    final filePath = '${dir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  String _formatPercentageChange(double percentageChange, bool isFirstMonth) {
    if (isFirstMonth) return 'First month';
    if (percentageChange == 0) return 'No change';
    final sign = percentageChange > 0 ? '+' : '';
    return '$sign${percentageChange.toStringAsFixed(1)}%';
  }

  pw.Widget _buildCategoryTable(
    List<({String name, double amount, double percentage})> breakdown,
  ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
      },
      headers: ['Category', 'Amount', '%'],
      data: breakdown.map((item) {
        return [
          item.name,
          CurrencyFormatter.format(item.amount),
          '${item.percentage.toStringAsFixed(1)}%',
        ];
      }).toList(),
    );
  }
}
