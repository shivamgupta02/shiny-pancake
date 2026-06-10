import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../screens/edit_expense_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
  });

  final Expense expense;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(category?.color ?? 0xFF757575);
    final categoryName = category?.name ?? 'Unknown';
    final displayText = expense.description?.isNotEmpty == true
        ? expense.description!
        : categoryName;

    return Dismissible(
      key: Key(expense.uid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        context.read<ExpenseBloc>().add(DeleteExpense(uid: expense.uid));
      },
      child: Semantics(
        label: 'Expense tile: $displayText, ${CurrencyFormatter.format(expense.amount)}',
        child: ListTile(
          key: const Key('expense-tile'),
          onTap: () => _navigateToEdit(context),
          onLongPress: () => _showDeleteDialog(context),
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            displayText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge,
          ),
          subtitle: Text(
            categoryName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(expense.amount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormatter.formatDayMonth(expense.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditExpenseScreen(expense: expense),
      ),
    );
    if (result == true && context.mounted) {
      context.read<ExpenseBloc>().add(const LoadExpenses(refresh: true));
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            key: const Key('cancel-delete-button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm-delete-button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed == true && context.mounted) {
      context.read<ExpenseBloc>().add(DeleteExpense(uid: expense.uid));
    }
  }
}
