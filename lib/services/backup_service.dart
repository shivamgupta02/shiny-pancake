import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../data/models/category.dart';
import '../data/models/expense.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../services/database_service.dart';

class BackupService {
  BackupService({
    required ExpenseRepository expenseRepository,
    required CategoryRepository categoryRepository,
    required SettingsRepository settingsRepository,
    required DatabaseService databaseService,
  })  : _expenseRepository = expenseRepository,
        _categoryRepository = categoryRepository,
        _settingsRepository = settingsRepository,
        _databaseService = databaseService;

  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;
  final SettingsRepository _settingsRepository;
  final DatabaseService _databaseService;

  static const int _backupVersion = 1;

  Future<String> createBackup() async {
    final expenses = await _expenseRepository.getAll();
    final categories = await _categoryRepository.getAll();
    final settings = await _settingsRepository.getSettings();

    final backupData = {
      'version': _backupVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'settings': settings.toJson(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/backup_$timestamp.json');
    await file.writeAsString(jsonString);

    await _settingsRepository.updateLastBackupDate();

    return file.path;
  }

  Future<bool> validateBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!data.containsKey('version')) return false;
      if (!data.containsKey('expenses')) return false;
      if (!data.containsKey('categories')) return false;
      if (!data.containsKey('settings')) return false;

      final version = data['version'] as int;
      if (version > _backupVersion) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreBackup(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    // Clear existing data
    await _databaseService.clearAll();

    // Restore categories
    final categoriesJson = data['categories'] as List<dynamic>;
    for (final categoryJson in categoriesJson) {
      final category =
          Category.fromJson(categoryJson as Map<String, dynamic>);
      // Re-create via direct database access pattern
      await _databaseService.categories.put(category.uid, category.toMap());
    }

    // Restore expenses
    final expensesJson = data['expenses'] as List<dynamic>;
    for (final expenseJson in expensesJson) {
      final expense = Expense.fromJson(expenseJson as Map<String, dynamic>);
      await _databaseService.expenses.put(expense.uid, expense.toMap());
    }

    // Restore settings
    final settingsJson = data['settings'] as Map<String, dynamic>;
    await _databaseService.settings.put('app_settings', {
      'userName': settingsJson['userName'] ?? '',
      'themeMode': settingsJson['themeMode'] ?? 0,
      'timeoutMinutes': settingsJson['timeoutMinutes'] ?? 1,
      'biometricEnabled': settingsJson['biometricEnabled'] ?? false,
      'onboardingComplete': true, // Keep onboarding complete after restore
      'smsEnabled': settingsJson['smsEnabled'] ?? false,
      'lastBackupDate': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
