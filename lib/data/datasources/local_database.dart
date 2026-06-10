import '../../services/database_service.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/app_settings.dart';

class LocalDatabase {
  LocalDatabase(this._databaseService);

  final DatabaseService _databaseService;

  // ─── Expense Operations ───────────────────────────────────────────────

  Future<List<Expense>> getAllExpenses({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? categoryIds,
    double? amountMin,
    double? amountMax,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    final box = _databaseService.expenses;
    var expenses = box.values
        .map((e) => Expense.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .where((e) {
      if (dateFrom != null && e.date.isBefore(dateFrom)) return false;
      if (dateTo != null && e.date.isAfter(dateTo)) return false;
      if (categoryIds != null &&
          categoryIds.isNotEmpty &&
          !categoryIds.contains(e.categoryId)) return false;
      if (amountMin != null && e.amount < amountMin) return false;
      if (amountMax != null && e.amount > amountMax) return false;
      if (searchQuery != null &&
          searchQuery.isNotEmpty &&
          !(e.description?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false)) return false;
      return true;
    }).toList();

    // Sort by date descending
    expenses.sort((a, b) => b.date.compareTo(a.date));

    if (offset != null) {
      expenses = expenses.skip(offset).toList();
    }
    if (limit != null) {
      expenses = expenses.take(limit).toList();
    }

    return expenses;
  }

  Future<Expense?> getExpenseByUid(String uid) async {
    final box = _databaseService.expenses;
    final data = box.get(uid);
    if (data == null) return null;
    return Expense.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  Future<Expense> createExpense(Expense expense) async {
    final box = _databaseService.expenses;
    await box.put(expense.uid, expense.toMap());
    return expense;
  }

  Future<Expense> updateExpense(Expense expense) async {
    final box = _databaseService.expenses;
    await box.put(expense.uid, expense.toMap());
    return expense;
  }

  Future<void> deleteExpense(String uid) async {
    final box = _databaseService.expenses;
    await box.delete(uid);
  }

  Future<double> getTotalByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final box = _databaseService.expenses;
    double total = 0;
    for (final data in box.values) {
      final expense = Expense.fromMap(Map<dynamic, dynamic>.from(data as Map));
      if (!expense.date.isBefore(start) && !expense.date.isAfter(end)) {
        total += expense.amount;
      }
    }
    return total;
  }

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final box = _databaseService.expenses;
    final expenses = box.values
        .map((e) => Expense.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<int> getExpenseCount() async {
    return _databaseService.expenses.length;
  }

  // ─── Category Operations ──────────────────────────────────────────────

  Future<List<Category>> getAllCategories() async {
    final box = _databaseService.categories;
    final categories = box.values
        .map((e) => Category.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  Future<Category?> getCategoryByUid(String uid) async {
    final box = _databaseService.categories;
    final data = box.get(uid);
    if (data == null) return null;
    return Category.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  Future<Category?> getCategoryByName(String name) async {
    final box = _databaseService.categories;
    for (final data in box.values) {
      final category =
          Category.fromMap(Map<dynamic, dynamic>.from(data as Map));
      if (category.name.toLowerCase() == name.toLowerCase()) {
        return category;
      }
    }
    return null;
  }

  Future<Category> createCategory(Category category) async {
    final box = _databaseService.categories;
    await box.put(category.uid, category.toMap());
    return category;
  }

  Future<Category> updateCategory(Category category) async {
    final box = _databaseService.categories;
    await box.put(category.uid, category.toMap());
    return category;
  }

  Future<void> deleteCategory(String uid) async {
    final box = _databaseService.categories;
    await box.delete(uid);
  }

  Future<int> getCategoryExpenseCount(String categoryUid) async {
    final box = _databaseService.expenses;
    int count = 0;
    for (final data in box.values) {
      final expense = Expense.fromMap(Map<dynamic, dynamic>.from(data as Map));
      if (expense.categoryId == categoryUid) count++;
    }
    return count;
  }

  Future<void> reassignExpenses(
      String fromCategoryId, String toCategoryId) async {
    final box = _databaseService.expenses;
    for (final key in box.keys.toList()) {
      final data = box.get(key);
      final expense = Expense.fromMap(Map<dynamic, dynamic>.from(data as Map));
      if (expense.categoryId == fromCategoryId) {
        final updated = expense.copyWith(categoryId: toCategoryId);
        await box.put(key, updated.toMap());
      }
    }
  }

  Future<int> getMaxSortOrder() async {
    final categories = await getAllCategories();
    if (categories.isEmpty) return -1;
    return categories
        .map((c) => c.sortOrder)
        .reduce((a, b) => a > b ? a : b);
  }

  // ─── Settings Operations ──────────────────────────────────────────────

  Future<AppSettings> getSettings() async {
    final box = _databaseService.settings;
    final data = box.get('app_settings');
    if (data == null) {
      final defaults = AppSettings.defaults();
      await box.put('app_settings', defaults.toMap());
      return defaults;
    }
    return AppSettings.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  Future<void> updateSettings(AppSettings settings) async {
    final box = _databaseService.settings;
    await box.put('app_settings', settings.toMap());
  }
}
