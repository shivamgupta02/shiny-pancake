import 'package:uuid/uuid.dart';

import '../datasources/local_database.dart';
import '../models/category.dart';
import '../../core/constants/app_constants.dart';

class CategoryRepository {
  CategoryRepository(this._localDatabase);

  final LocalDatabase _localDatabase;
  static const _uuid = Uuid();

  Future<List<Category>> getAll() async {
    return _localDatabase.getAllCategories();
  }

  Future<Category?> getByUid(String uid) async {
    return _localDatabase.getCategoryByUid(uid);
  }

  Future<Category?> getByName(String name) async {
    return _localDatabase.getCategoryByName(name);
  }

  Future<Category> create({
    required String name,
    required String icon,
    required int color,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty ||
        trimmedName.length > AppConstants.maxCategoryNameLength) {
      throw ArgumentError(
          'Category name must be 1-${AppConstants.maxCategoryNameLength} characters');
    }

    final existing = await _localDatabase.getCategoryByName(trimmedName);
    if (existing != null) {
      throw ArgumentError('A category with this name already exists');
    }

    final maxOrder = await _localDatabase.getMaxSortOrder();

    final category = Category.create(
      uid: _uuid.v4(),
      name: trimmedName,
      icon: icon,
      color: color,
      isDefault: false,
      sortOrder: maxOrder + 1,
    );

    return _localDatabase.createCategory(category);
  }

  Future<Category> update(Category category) async {
    if (category.isDefault) {
      throw ArgumentError('Default categories cannot be modified');
    }
    return _localDatabase.updateCategory(category);
  }

  Future<void> delete(String uid, {required String reassignToId}) async {
    final category = await _localDatabase.getCategoryByUid(uid);
    if (category == null) return;

    if (category.isDefault) {
      throw ArgumentError('Default categories cannot be deleted');
    }

    await _localDatabase.reassignExpenses(uid, reassignToId);
    await _localDatabase.deleteCategory(uid);
  }

  Future<int> getExpenseCount(String categoryUid) async {
    return _localDatabase.getCategoryExpenseCount(categoryUid);
  }

  Future<void> seedDefaults() async {
    final existing = await _localDatabase.getAllCategories();
    if (existing.isNotEmpty) return;

    final defaults = _getDefaultCategories();
    for (final category in defaults) {
      await _localDatabase.createCategory(category);
    }
  }

  List<Category> _getDefaultCategories() {
    final categories = [
      ('Food & Dining', 'restaurant', 0xFFE53935, 0),
      ('Groceries', 'shopping_cart', 0xFF43A047, 1),
      ('Transport', 'directions_car', 0xFF1E88E5, 2),
      ('Fuel', 'local_gas_station', 0xFFFB8C00, 3),
      ('Rent', 'home', 0xFF8E24AA, 4),
      ('Utilities', 'bolt', 0xFFFFB300, 5),
      ('Shopping', 'shopping_bag', 0xFFD81B60, 6),
      ('Entertainment', 'movie', 0xFF5E35B1, 7),
      ('Health', 'local_hospital', 0xFF00897B, 8),
      ('Education', 'school', 0xFF3949AB, 9),
      ('Travel', 'flight', 0xFF00ACC1, 10),
      ('Subscriptions', 'subscriptions', 0xFF6D4C41, 11),
      ('Other', 'more_horiz', 0xFF757575, 12),
    ];

    return categories.map((c) {
      return Category.create(
        uid: _uuid.v4(),
        name: c.$1,
        icon: c.$2,
        color: c.$3,
        isDefault: true,
        sortOrder: c.$4,
      );
    }).toList();
  }
}
