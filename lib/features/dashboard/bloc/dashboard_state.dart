import 'package:equatable/equatable.dart';

import '../../../data/models/expense.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.monthTotal,
    required this.previousMonthTotal,
    required this.percentageChange,
    required this.isFirstMonth,
    required this.categoryBreakdown,
    required this.dailyTotals,
    required this.topCategories,
    required this.recentExpenses,
    required this.selectedMonth,
    required this.averageDaily,
  });

  final double monthTotal;
  final double previousMonthTotal;
  final double percentageChange;
  final bool isFirstMonth;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<DailyTotal> dailyTotals;
  final List<CategoryBreakdownItem> topCategories;
  final List<Expense> recentExpenses;
  final DateTime selectedMonth;
  final double averageDaily;

  @override
  List<Object?> get props => [
        monthTotal,
        previousMonthTotal,
        percentageChange,
        isFirstMonth,
        categoryBreakdown,
        dailyTotals,
        topCategories,
        recentExpenses,
        selectedMonth,
        averageDaily,
      ];
}

class DashboardError extends DashboardState {
  const DashboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class CategoryBreakdownItem extends Equatable {
  const CategoryBreakdownItem({
    required this.categoryUid,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.amount,
    required this.percentage,
  });

  final String categoryUid;
  final String categoryName;
  final int categoryColor;
  final String categoryIcon;
  final double amount;
  final double percentage;

  @override
  List<Object?> get props => [
        categoryUid,
        categoryName,
        categoryColor,
        categoryIcon,
        amount,
        percentage,
      ];
}

class DailyTotal extends Equatable {
  const DailyTotal({
    required this.day,
    required this.amount,
  });

  final int day;
  final double amount;

  @override
  List<Object?> get props => [day, amount];
}
