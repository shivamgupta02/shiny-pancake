import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<ChangeMonth>(_onChangeMonth);
  }

  final ExpenseRepository _expenseRepository = getIt<ExpenseRepository>();
  final CategoryRepository _categoryRepository = getIt<CategoryRepository>();

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(const DashboardLoading());
      final selectedMonth = event.month ?? DateTime.now();
      await _loadDashboardData(selectedMonth, emit);
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(const DashboardLoading());
      await _loadDashboardData(event.month, emit);
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _loadDashboardData(
    DateTime month,
    Emitter<DashboardState> emit,
  ) async {
    // Get current month total
    final monthTotal = await _expenseRepository.getTotalByMonth(month);

    // Get previous month total for comparison
    final previousMonth = DateTime(month.year, month.month - 1, 1);
    final previousMonthTotal =
        await _expenseRepository.getTotalByMonth(previousMonth);

    // Calculate percentage change
    final isFirstMonth = previousMonthTotal == 0;
    double percentageChange = 0;
    if (!isFirstMonth) {
      percentageChange =
          ((monthTotal - previousMonthTotal) / previousMonthTotal) * 100;
    }

    // Get expenses for current month
    final monthExpenses = await _expenseRepository.getByMonth(month);

    // Get all categories
    final categories = await _categoryRepository.getAll();
    final categoryMap = {for (final c in categories) c.uid: c};

    // Calculate category breakdown
    final categoryTotals = <String, double>{};
    for (final expense in monthExpenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    // Sort by amount descending
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Build breakdown with top 5 + Others
    final categoryBreakdown = <CategoryBreakdownItem>[];
    double othersTotal = 0;

    for (var i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      final category = categoryMap[entry.key];
      final percentage =
          monthTotal > 0 ? (entry.value / monthTotal) * 100 : 0.0;

      if (i < 5) {
        categoryBreakdown.add(CategoryBreakdownItem(
          categoryUid: entry.key,
          categoryName: category?.name ?? 'Unknown',
          categoryColor: category?.color ?? 0xFF757575,
          categoryIcon: category?.icon ?? 'category',
          amount: entry.value,
          percentage: percentage,
        ));
      } else {
        othersTotal += entry.value;
      }
    }

    // Add "Others" if more than 5 categories
    if (sortedCategories.length > 5 && othersTotal > 0) {
      final othersPercentage =
          monthTotal > 0 ? (othersTotal / monthTotal) * 100 : 0.0;
      categoryBreakdown.add(CategoryBreakdownItem(
        categoryUid: 'others',
        categoryName: 'Others',
        categoryColor: 0xFF757575,
        categoryIcon: 'more_horiz',
        amount: othersTotal,
        percentage: othersPercentage,
      ));
    }

    // Calculate daily totals
    final daysInMonth = DateFormatter.daysInMonth(month);
    final dailyTotals = <DailyTotal>[];
    final dailyMap = <int, double>{};

    for (final expense in monthExpenses) {
      final day = expense.date.day;
      dailyMap[day] = (dailyMap[day] ?? 0) + expense.amount;
    }

    for (var day = 1; day <= daysInMonth; day++) {
      dailyTotals.add(DailyTotal(
        day: day,
        amount: dailyMap[day] ?? 0,
      ));
    }

    // Calculate daily average
    final daysWithSpending =
        dailyTotals.where((d) => d.amount > 0).length;
    final averageDaily =
        daysWithSpending > 0 ? monthTotal / daysWithSpending : 0.0;

    // Top categories (same as breakdown but limited to actual categories, no "Others")
    final topCategories = categoryBreakdown
        .where((item) => item.categoryUid != 'others')
        .take(5)
        .toList();

    // Recent expenses (last 10)
    final allExpenses = await _expenseRepository.getAll(limit: 10);

    emit(DashboardLoaded(
      monthTotal: monthTotal,
      previousMonthTotal: previousMonthTotal,
      percentageChange: percentageChange,
      isFirstMonth: isFirstMonth,
      categoryBreakdown: categoryBreakdown,
      dailyTotals: dailyTotals,
      topCategories: topCategories,
      recentExpenses: allExpenses,
      selectedMonth: month,
      averageDaily: averageDaily,
    ));
  }
}
