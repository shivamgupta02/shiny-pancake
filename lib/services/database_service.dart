import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String expensesBox = 'expenses';
  static const String categoriesBox = 'categories';
  static const String settingsBox = 'settings';
  static const String smsRulesBox = 'sms_rules';

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(expensesBox);
    await Hive.openBox(categoriesBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(smsRulesBox);
  }

  Box get expenses => Hive.box(expensesBox);
  Box get categories => Hive.box(categoriesBox);
  Box get settings => Hive.box(settingsBox);
  Box get smsRules => Hive.box(smsRulesBox);

  Future<void> close() async {
    await Hive.close();
  }

  Future<void> clearAll() async {
    await expenses.clear();
    await categories.clear();
    await settings.clear();
    await smsRules.clear();
  }

  int getSize() {
    return expenses.length + categories.length + settings.length;
  }
}
