import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/expense_filter.dart';
import '../../../data/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<SearchExpenses>(_onSearchExpenses);
    on<ApplyFilter>(_onApplyFilter);
  }

  final ExpenseRepository _expenseRepository = getIt<ExpenseRepository>();
  ExpenseFilter? _currentFilter;

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final currentState = state;
      final isRefresh = event.refresh;

      if (currentState is! ExpenseLoaded || isRefresh) {
        emit(const ExpenseLoading());
      }

      final offset = isRefresh || currentState is! ExpenseLoaded
          ? 0
          : currentState.expenses.length;

      final expenses = await _expenseRepository.getAll(
        filter: _currentFilter,
        limit: AppConstants.expensesPerPage,
        offset: offset,
      );

      final hasMore = expenses.length >= AppConstants.expensesPerPage;

      if (isRefresh || currentState is! ExpenseLoaded) {
        emit(ExpenseLoaded(
          expenses: expenses,
          hasMore: hasMore,
          filter: _currentFilter,
        ));
      } else {
        emit(ExpenseLoaded(
          expenses: [...currentState.expenses, ...expenses],
          hasMore: hasMore,
          filter: _currentFilter,
        ));
      }
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _expenseRepository.create(
        amount: event.amount,
        categoryId: event.categoryId,
        description: event.description,
        date: event.date,
        source: event.source,
      );
      add(const LoadExpenses(refresh: true));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _expenseRepository.update(event.expense);
      add(const LoadExpenses(refresh: true));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _expenseRepository.delete(event.uid);
      add(const LoadExpenses(refresh: true));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onSearchExpenses(
    SearchExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    _currentFilter = _currentFilter?.copyWith(searchQuery: event.query) ??
        ExpenseFilter(searchQuery: event.query);
    add(const LoadExpenses(refresh: true));
  }

  Future<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<ExpenseState> emit,
  ) async {
    _currentFilter = event.filter;
    add(const LoadExpenses(refresh: true));
  }
}
