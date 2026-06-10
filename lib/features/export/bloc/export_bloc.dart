import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_filter.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../services/export_service.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  ExportBloc() : super(const ExportInitial()) {
    on<ExportToExcel>(_onExportToExcel);
    on<ExportToPdf>(_onExportToPdf);
    on<ShareExportedFile>(_onShareFile);
  }

  final ExpenseRepository _expenseRepository = getIt<ExpenseRepository>();
  final CategoryRepository _categoryRepository = getIt<CategoryRepository>();
  final ExportService _exportService = getIt<ExportService>();

  Future<void> _onExportToExcel(
    ExportToExcel event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportInProgress('Generating Excel file...'));

    try {
      final filter = ExpenseFilter(
        dateFrom: event.dateFrom,
        dateTo: DateTime(
          event.dateTo.year,
          event.dateTo.month,
          event.dateTo.day,
          23,
          59,
          59,
        ),
        categoryIds: event.categoryIds,
      );

      final expenses = await _expenseRepository.getAll(filter: filter);
      final categories = await _categoryRepository.getAll();

      final filePath = await _exportService.generateExcel(
        expenses,
        categories,
        event.dateFrom,
        event.dateTo,
      );

      emit(ExportSuccess(filePath));
    } catch (e) {
      emit(ExportError('Failed to export Excel: $e'));
    }
  }

  Future<void> _onExportToPdf(
    ExportToPdf event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportInProgress('Generating PDF report...'));

    try {
      final month = DateTime(event.month.year, event.month.month, 1);
      final daysInMonth = DateFormatter.daysInMonth(month);

      // Current month expenses
      final expenses = await _expenseRepository.getByMonth(month);
      final categories = await _categoryRepository.getAll();

      // Previous month expenses
      final prevMonth = DateTime(month.year, month.month - 1, 1);
      final prevExpenses = await _expenseRepository.getByMonth(prevMonth);

      // Check if first month
      final prevMonthLastDay = DateTime(
        prevMonth.year,
        prevMonth.month,
        DateFormatter.daysInMonth(prevMonth),
        23,
        59,
        59,
      );
      final allPriorExpenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateTo: prevMonthLastDay),
      );
      final isFirstMonth = allPriorExpenses.isEmpty;

      // Calculations
      final totalSpent = _sumExpenses(expenses);
      final previousMonthTotal = _sumExpenses(prevExpenses);
      final averageDaily = totalSpent / daysInMonth;

      double percentageChange = 0;
      if (!isFirstMonth && previousMonthTotal > 0) {
        percentageChange =
            ((totalSpent - previousMonthTotal) / previousMonthTotal) * 100;
      }

      // Category breakdown
      final categoryMap = <String, String>{};
      for (final cat in categories) {
        categoryMap[cat.uid] = cat.name;
      }

      final categoryTotals = <String, double>{};
      for (final expense in expenses) {
        final name = categoryMap[expense.categoryId] ?? 'Unknown';
        categoryTotals[name] = (categoryTotals[name] ?? 0) + expense.amount;
      }

      final categoryBreakdown =
          categoryTotals.entries.map((entry) {
        final percentage =
            totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
        return (
          name: entry.key,
          amount: entry.value,
          percentage: percentage,
        );
      }).toList()
            ..sort((a, b) => b.amount.compareTo(a.amount));

      final filePath = await _exportService.generatePdf(
        totalSpent: totalSpent,
        averageDaily: averageDaily,
        percentageChange: percentageChange,
        isFirstMonth: isFirstMonth,
        categoryBreakdown: categoryBreakdown,
        month: month,
      );

      emit(ExportSuccess(filePath));
    } catch (e) {
      emit(ExportError('Failed to export PDF: $e'));
    }
  }

  Future<void> _onShareFile(
    ShareExportedFile event,
    Emitter<ExportState> emit,
  ) async {
    try {
      await _exportService.shareFile(event.filePath);
    } catch (e) {
      emit(ExportError('Failed to share file: $e'));
    }
  }

  double _sumExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }
}
