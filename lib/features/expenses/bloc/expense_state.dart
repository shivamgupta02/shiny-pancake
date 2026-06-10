import 'package:equatable/equatable.dart';

import '../../../data/models/expense.dart';
import '../../../data/models/expense_filter.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({
    required this.expenses,
    required this.hasMore,
    this.filter,
  });

  final List<Expense> expenses;
  final bool hasMore;
  final ExpenseFilter? filter;

  @override
  List<Object?> get props => [expenses, hasMore, filter];
}

class ExpenseError extends ExpenseState {
  const ExpenseError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
