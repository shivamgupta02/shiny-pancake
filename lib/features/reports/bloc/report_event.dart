import 'package:flutter/foundation.dart';

@immutable
sealed class ReportEvent {
  const ReportEvent();
}

class LoadWeeklyReport extends ReportEvent {
  final DateTime weekStart;

  const LoadWeeklyReport(this.weekStart);
}

class LoadMonthlyReport extends ReportEvent {
  final DateTime month;

  const LoadMonthlyReport(this.month);
}
