import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonth = DateFormat('MMM yyyy');
  static final DateFormat _dayOfWeek = DateFormat('EEE');
  static final DateFormat _exportDate = DateFormat('yyyy-MM-dd');

  /// Format as "09 Jun 2026"
  static String formatFull(DateTime date) => _dayMonthYear.format(date);

  /// Format as "09 Jun"
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);

  /// Format as "June 2026"
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// Format as "Jun 2026"
  static String formatShortMonthYear(DateTime date) => _shortMonth.format(date);

  /// Format as "Mon", "Tue", etc.
  static String formatDayOfWeek(DateTime date) => _dayOfWeek.format(date);

  /// Format as "2026-06-09" for export filenames
  static String formatForExport(DateTime date) => _exportDate.format(date);

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get first day of month
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get Monday of the week containing date
  static DateTime mondayOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Get number of days in a month
  static int daysInMonth(DateTime date) {
    return lastDayOfMonth(date).day;
  }
}
