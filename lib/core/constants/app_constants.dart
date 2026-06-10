class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Expense Calculator';
  static const String appVersion = '1.0.0';

  // Validation limits
  static const double maxExpenseAmount = 10000000.0;
  static const int maxDescriptionLength = 200;
  static const int maxCategoryNameLength = 30;
  static const int pinLength = 4;

  // Pagination
  static const int expensesPerPage = 20;

  // Data retention
  static const int maxDataRetentionYears = 2;

  // Timeout options (in minutes)
  static const List<int> timeoutOptions = [0, 1, 5, 15];

  // PIN lockout
  static const int maxPinAttempts = 3;
  static const int shortLockoutSeconds = 30;
  static const int longLockoutAttempts = 5;
  static const int longLockoutMinutes = 5;

  // SMS scan
  static const int defaultSmsScanDays = 7;

  // Dashboard
  static const int recentTransactionsLimit = 10;
  static const int topCategoriesLimit = 5;

  // Export
  static const String excelFilePrefix = 'expenses_';
  static const String pdfFilePrefix = 'report_';
}
