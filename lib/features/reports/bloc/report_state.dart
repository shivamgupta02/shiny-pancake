import 'package:flutter/foundation.dart' hide Category;

import '../../../data/models/category.dart';

@immutable
sealed class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class CategoryBreakdownItem {
  final Category category;
  final double total;
  final double percentage;

  const CategoryBreakdownItem({
    required this.category,
    required this.total,
    required this.percentage,
  });
}

class WeeklyReportLoaded extends ReportState {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double totalSpent;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<double> dailyTotals; // 7 items: Mon-Sun
  final double previousWeekTotal;
  final double? percentageChange;
  final bool isFirstWeek;
  final double averageDaily;

  const WeeklyReportLoaded({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSpent,
    required this.categoryBreakdown,
    required this.dailyTotals,
    required this.previousWeekTotal,
    required this.percentageChange,
    required this.isFirstWeek,
    required this.averageDaily,
  });
}

class MonthlyReportLoaded extends ReportState {
  final DateTime month;
  final double totalSpent;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<double> dailyTotals;
  final List<CategoryBreakdownItem> topCategories;
  final double averageDaily;
  final double previousMonthTotal;
  final double? percentageChange;
  final bool isFirstMonth;
  final int daysInMonth;

  const MonthlyReportLoaded({
    required this.month,
    required this.totalSpent,
    required this.categoryBreakdown,
    required this.dailyTotals,
    required this.topCategories,
    required this.averageDaily,
    required this.previousMonthTotal,
    required this.percentageChange,
    required this.isFirstMonth,
    required this.daysInMonth,
  });
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);
}
