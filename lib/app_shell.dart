import 'package:flutter/material.dart';

import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/expenses/screens/expense_list_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Use keys to force rebuild when tab is selected
  Key _dashboardKey = UniqueKey();
  Key _reportsKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            // Force dashboard and reports to reload fresh data on tab switch
            if (index == 0) _dashboardKey = UniqueKey();
            if (index == 2) _reportsKey = UniqueKey();
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(key: _dashboardKey);
      case 1:
        return const ExpenseListScreen();
      case 2:
        return ReportsScreen(key: _reportsKey);
      case 3:
        return const SettingsScreen();
      default:
        return DashboardScreen(key: _dashboardKey);
    }
  }
}
