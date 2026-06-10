import 'package:uuid/uuid.dart';

import '../datasources/local_database.dart';
import '../models/expense.dart';
import '../models/expense_filter.dart';

class ExpenseRepository {
  ExpenseRepository(this._localDatabase);

  final LocalDatabase _localDatabase;
  static const _uuid = Uuid();

  Future<List<Expense>> getAll({
    ExpenseFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return _localDatabase.getAllExpenses(
      dateFrom: filter?.dateFrom,
      dateTo: filter?.dateTo,
      categoryIds: filter?.categoryIds,
      amountMin: filter?.amountMin,
      amountMax: filter?.amountMax,
      searchQuery: filter?.searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  Future<Expense?> getByUid(String uid) async {
    return _localDatabase.getExpenseByUid(uid);
  }

  Future<Expense> create({
    required double amount,
    required String categoryId,
    String? description,
    required DateTime date,
    required ExpenseSource source,
  }) async {
    final expense = Expense.create(
      uid: _uuid.v4(),
      amount: amount,
      categoryId: categoryId,
      description: description?.trim(),
      date: date,
      source: source,
    );
    return _localDatabase.createExpense(expense);
  }

  Future<Expense> update(Expense expense) async {
    final updated = expense.copyWith();
    return _localDatabase.updateExpense(updated);
  }

  Future<void> delete(String uid) async {
    await _localDatabase.deleteExpense(uid);
  }

  Future<double> getTotalByMonth(DateTime month) async {
    return _localDatabase.getTotalByMonth(month);
  }

  Future<List<Expense>> getByMonth(DateTime month) async {
    return _localDatabase.getExpensesByMonth(month);
  }

  Future<int> getCount() async {
    return _localDatabase.getExpenseCount();
  }
}
