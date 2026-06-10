import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrCompactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  /// Format amount as INR (e.g., ₹1,23,456.78)
  static String format(double amount) {
    return _inrFormat.format(amount);
  }

  /// Format amount as compact INR (e.g., ₹1.2L)
  static String formatCompact(double amount) {
    return _inrCompactFormat.format(amount);
  }

  /// Format amount without symbol (e.g., 1,23,456.78)
  static String formatWithoutSymbol(double amount) {
    return NumberFormat('#,##,##0.00', 'en_IN').format(amount);
  }
}
