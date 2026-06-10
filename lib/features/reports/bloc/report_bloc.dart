import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_filter.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(const ReportInitial()) {
    on<LoadWeeklyReport>(_onLoadWeeklyReport);
    on<LoadMonthlyReport>(_onLoadMonthlyReport);
  }

  final ExpenseRepository _expenseRepository = getIt<ExpenseRepository>();
  final CategoryRepository _categoryRepository = getIt<CategoryRepository>();

  Future<void> _onLoadWeeklyReport(
    LoadWeeklyReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    try {
      final weekStart = DateTime(
        event.weekStart.year,
        event.weekStart.month,
        event.weekStart.day,
      );
      final weekEnd = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + 6,
        23,
        59,
        59,
      );

      // Fetch expenses for current week
      final expenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateFrom: weekStart, dateTo: weekEnd),
      );

      // Fetch expenses for previous week
      final prevWeekStart = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day - 7,
      );
      final prevWeekEnd = DateTime(
        prevWeekStart.year,
        prevWeekStart.month,
        prevWeekStart.day + 6,
        23,
        59,
        59,
      );
      final prevExpenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateFrom: prevWeekStart, dateTo: prevWeekEnd),
      );

      // Check if this is the first week (no expenses before current week)
      final allPriorExpenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateTo: prevWeekEnd),
      );
      final isFirstWeek = allPriorExpenses.isEmpty;

      // Total spent
      final totalSpent = _sumExpenses(expenses);
      final previousWeekTotal = _sumExpenses(prevExpenses);

      // Percentage change
      final percentageChange = _calculatePercentageChange(
        current: totalSpent,
        previous: previousWeekTotal,
        isFirstPeriod: isFirstWeek,
      );

      // Category breakdown
      final categories = await _categoryRepository.getAll();
      final categoryBreakdown = _buildCategoryBreakdown(expenses, categories);

      // Daily totals (Mon-Sun)
      final dailyTotals = List<double>.filled(7, 0.0);
      for (final expense in expenses) {
        final dayIndex = expense.date.weekday - 1; // Monday = 0
        dailyTotals[dayIndex] += expense.amount;
      }

      // Average daily
      final averageDaily = totalSpent / 7;

      emit(WeeklyReportLoaded(
        weekStart: weekStart,
        weekEnd: weekEnd,
        totalSpent: totalSpent,
        categoryBreakdown: categoryBreakdown,
        dailyTotals: dailyTotals,
        previousWeekTotal: previousWeekTotal,
        percentageChange: percentageChange,
        isFirstWeek: isFirstWeek,
        averageDaily: averageDaily,
      ));
    } catch (e) {
      emit(ReportError('Failed to load weekly report: $e'));
    }
  }

  Future<void> _onLoadMonthlyReport(
    LoadMonthlyReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    try {
      final month = DateTime(event.month.year, event.month.month, 1);
      final daysInMonth = DateFormatter.daysInMonth(month);

      // Fetch expenses for current month
      final firstDay = DateFormatter.firstDayOfMonth(month);
      final lastDay = DateTime(
        month.year,
        month.month,
        daysInMonth,
        23,
        59,
        59,
      );
      final expenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateFrom: firstDay, dateTo: lastDay),
      );

      // Fetch expenses for previous month
      final prevMonth = DateTime(month.year, month.month - 1, 1);
      final prevDaysInMonth = DateFormatter.daysInMonth(prevMonth);
      final prevFirstDay = DateFormatter.firstDayOfMonth(prevMonth);
      final prevLastDay = DateTime(
        prevMonth.year,
        prevMonth.month,
        prevDaysInMonth,
        23,
        59,
        59,
      );
      final prevExpenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateFrom: prevFirstDay, dateTo: prevLastDay),
      );

      // Check if this is the first month
      final allPriorExpenses = await _expenseRepository.getAll(
        filter: ExpenseFilter(dateTo: prevLastDay),
      );
      final isFirstMonth = allPriorExpenses.isEmpty;

      // Totals
      final totalSpent = _sumExpenses(expenses);
      final previousMonthTotal = _sumExpenses(prevExpenses);

      // Percentage change
      final percentageChange = _calculatePercentageChange(
        current: totalSpent,
        previous: previousMonthTotal,
        isFirstPeriod: isFirstMonth,
      );

      // Category breakdown
      final categories = await _categoryRepository.getAll();
      final categoryBreakdown = _buildCategoryBreakdown(expenses, categories);

      // Top 5 categories
      final topCategories = categoryBreakdown.take(5).toList();

      // Daily totals for each day of the month
      final dailyTotals = List<double>.filled(daysInMonth, 0.0);
      for (final expense in expenses) {
        final dayIndex = expense.date.day - 1;
        if (dayIndex >= 0 && dayIndex < daysInMonth) {
          dailyTotals[dayIndex] += expense.amount;
        }
      }

      // Average daily
      final averageDaily = totalSpent / daysInMonth;

      emit(MonthlyReportLoaded(
        month: month,
        totalSpent: totalSpent,
        categoryBreakdown: categoryBreakdown,
        dailyTotals: dailyTotals,
        topCategories: topCategories,
        averageDaily: averageDaily,
        previousMonthTotal: previousMonthTotal,
        percentageChange: percentageChange,
        isFirstMonth: isFirstMonth,
        daysInMonth: daysInMonth,
      ));
    } catch (e) {
      emit(ReportError('Failed to load monthly report: $e'));
    }
  }

  double _sumExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Returns null for "New" case (previous=0, current>0),
  /// returns 0.0 for "No expenses" case (both zero),
  /// returns the percentage for normal cases.
  double? _calculatePercentageChange({
    required double current,
    required double previous,
    required bool isFirstPeriod,
  }) {
    if (isFirstPeriod) return null; // Will show "First week/month"

    if (previous == 0 && current == 0) {
      return 0.0; // "No expenses"
    }
    if (previous == 0 && current > 0) {
      return null; // "New"
    }

    return ((current - previous) / previous) * 100;
  }

  List<CategoryBreakdownItem> _buildCategoryBreakdown(
    List<Expense> expenses,
    List<Category> categories,
  ) {
    if (expenses.isEmpty) return [];

    final categoryMap = <String, Category>{};
    for (final cat in categories) {
      categoryMap[cat.uid] = cat;
    }

    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.categoryId] =
          (totals[expense.categoryId] ?? 0) + expense.amount;
    }

    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final items = <CategoryBreakdownItem>[];
    for (final entry in totals.entries) {
      final category = categoryMap[entry.key];
      if (category != null) {
        items.add(CategoryBreakdownItem(
          category: category,
          total: entry.value,
          percentage: totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0,
        ));
      }
    }

    // Sort descending by total
    items.sort((a, b) => b.total.compareTo(a.total));
    return items;
  }
}
