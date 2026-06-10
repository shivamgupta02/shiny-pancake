import 'package:flutter/material.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/expenses/screens/expense_list_screen.dart';
import '../../features/reports/screens/reports_screen.dart';

class AppRouter {
  AppRouter._();

  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String editExpense = '/expenses/edit';
  static const String reports = '/reports';
  static const String weeklyReport = '/reports/weekly';
  static const String monthlyReport = '/reports/monthly';
  static const String settings = '/settings';
  static const String categories = '/categories';
  static const String createCategory = '/categories/create';
  static const String export = '/export';
  static const String onboarding = '/onboarding';
  static const String pinEntry = '/pin';
  static const String smsConfirmation = '/sms/confirm';
  static const String backup = '/settings/backup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      case expenses:
        return MaterialPageRoute(
          builder: (_) => const ExpenseListScreen(),
        );
      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
