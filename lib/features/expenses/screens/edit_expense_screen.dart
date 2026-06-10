import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/category_repository.dart';
import '../../categories/widgets/category_picker.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key, required this.expense});

  final Expense expense;

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  Category? _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description ?? '',
    );
    _selectedDate = widget.expense.date;
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final category =
        await getIt<CategoryRepository>().getByUid(widget.expense.categoryId);
    if (mounted && category != null) {
      setState(() => _selectedCategory = category);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => ExpenseBloc(),
      child: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseLoaded) {
            Navigator.of(context).pop(true);
          } else if (state is ExpenseError) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Expense'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Amount Field
                TextFormField(
                  key: const Key('amount-field'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: const OutlineInputBorder(),
                    helperText: 'Max: ₹${AppConstants.maxExpenseAmount.toStringAsFixed(0)}',
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 16),

                // Category Picker
                Semantics(
                  label: 'Category picker',
                  child: InkWell(
                    key: const Key('category-picker-button'),
                    onTap: _pickCategory,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: const OutlineInputBorder(),
                        errorText: _selectedCategory == null && _isSaving
                            ? 'Please select a category'
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (_selectedCategory != null) ...[
                            CircleAvatar(
                              backgroundColor: Color(_selectedCategory!.color),
                              radius: 12,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedCategory!.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ] else
                            Text(
                              'Select a category',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  key: const Key('description-field'),
                  controller: _descriptionController,
                  maxLength: AppConstants.maxDescriptionLength,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 16),

                // Date Picker
                Semantics(
                  label: 'Date picker',
                  child: InkWell(
                    key: const Key('date-picker-button'),
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormatter.formatFull(_selectedDate),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                FilledButton(
                  key: const Key('save-expense-button'),
                  onPressed: _isSaving ? null : () => _save(context),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > AppConstants.maxExpenseAmount) {
      return 'Amount cannot exceed ₹${AppConstants.maxExpenseAmount.toStringAsFixed(0)}';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Description cannot exceed ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  Future<void> _pickCategory() async {
    final category = await CategoryPicker.show(context);
    if (category != null) {
      setState(() => _selectedCategory = category);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save(BuildContext context) {
    setState(() => _isSaving = true);

    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      setState(() => _isSaving = false);
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    final updatedExpense = widget.expense.copyWith(
      amount: amount,
      categoryId: _selectedCategory!.uid,
      description: description,
      date: _selectedDate,
    );

    context.read<ExpenseBloc>().add(UpdateExpense(expense: updatedExpense));
  }
}
