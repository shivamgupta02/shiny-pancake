import 'package:equatable/equatable.dart';

import '../../../data/models/expense.dart';
import '../../../data/models/expense_filter.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

class AddExpense extends ExpenseEvent {
  const AddExpense({
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    this.source = ExpenseSource.manual,
  });

  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final ExpenseSource source;

  @override
  List<Object?> get props => [amount, categoryId, description, date, source];
}

class UpdateExpense extends ExpenseEvent {
  const UpdateExpense({required this.expense});

  final Expense expense;

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  const DeleteExpense({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class SearchExpenses extends ExpenseEvent {
  const SearchExpenses({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class ApplyFilter extends ExpenseEvent {
  const ApplyFilter({this.filter});

  final ExpenseFilter? filter;

  @override
  List<Object?> get props => [filter];
}
