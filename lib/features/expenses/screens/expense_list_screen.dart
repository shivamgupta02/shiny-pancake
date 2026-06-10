import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, Category> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await getIt<CategoryRepository>().getAll();
    if (mounted) {
      setState(() {
        _categoryMap = {for (final c in categories) c.uid: c};
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ExpenseBloc>().add(const LoadExpenses());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseBloc()..add(const LoadExpenses(refresh: true)),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          floatingActionButton: FloatingActionButton(
            key: const Key('add-expense-fab'),
            onPressed: () => _navigateToAdd(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          key: const Key('close-search-button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
            context.read<ExpenseBloc>().add(const SearchExpenses(query: ''));
          },
        ),
        title: TextField(
          key: const Key('search-expenses-field'),
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search expenses...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            context.read<ExpenseBloc>().add(SearchExpenses(query: query));
          },
        ),
      );
    }

    return AppBar(
      title: const Text('Expenses'),
      actions: [
        IconButton(
          key: const Key('search-toggle-button'),
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() => _isSearching = true);
          },
        ),
        BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            final hasFilter = state is ExpenseLoaded &&
                state.filter != null &&
                state.filter!.hasActiveFilters;
            return IconButton(
              key: const Key('filter-button'),
              icon: Icon(
                hasFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              onPressed: () => _showFilterSheet(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ExpenseError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    context.read<ExpenseBloc>().add(const LoadExpenses(refresh: true));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ExpenseLoaded) {
          if (state.expenses.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildExpenseList(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first expense',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, ExpenseLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExpenseBloc>().add(const LoadExpenses(refresh: true));
        await Future.delayed(const Duration(milliseconds: 500));
        _loadCategories();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.hasMore
            ? state.expenses.length + 1
            : state.expenses.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= state.expenses.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final expense = state.expenses[index];
          final category = _categoryMap[expense.categoryId];
          return ExpenseTile(
            expense: expense,
            category: category,
          );
        },
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final currentState = context.read<ExpenseBloc>().state;
    final currentFilter =
        currentState is ExpenseLoaded ? currentState.filter : null;

    final filter = await FilterBottomSheet.show(
      context,
      currentFilter: currentFilter,
    );

    if (filter != null && context.mounted) {
      context.read<ExpenseBloc>().add(ApplyFilter(filter: filter));
    }
  }

  void _navigateToAdd(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (result == true && context.mounted) {
      context.read<ExpenseBloc>().add(const LoadExpenses(refresh: true));
    }
  }
}
