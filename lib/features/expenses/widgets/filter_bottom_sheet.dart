import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/category.dart';
import '../../../data/models/expense_filter.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, this.currentFilter});

  final ExpenseFilter? currentFilter;

  static Future<ExpenseFilter?> show(
    BuildContext context, {
    ExpenseFilter? currentFilter,
  }) {
    return showModalBottomSheet<ExpenseFilter?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBloc()..add(const LoadCategories()),
        child: FilterBottomSheet(currentFilter: currentFilter),
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<String> _selectedCategoryIds = [];
  final TextEditingController _amountMinController = TextEditingController();
  final TextEditingController _amountMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = widget.currentFilter;
    if (filter != null) {
      _dateFrom = filter.dateFrom;
      _dateTo = filter.dateTo;
      _selectedCategoryIds = List.from(filter.categoryIds ?? []);
      if (filter.amountMin != null) {
        _amountMinController.text = filter.amountMin.toString();
      }
      if (filter.amountMax != null) {
        _amountMaxController.text = filter.amountMax.toString();
      }
    }
  }

  @override
  void dispose() {
    _amountMinController.dispose();
    _amountMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Expenses',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    key: const Key('close-filter-button'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Range
              Text('Date Range', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('date-from-button'),
                      onPressed: () => _pickDate(isFrom: true),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _dateFrom != null
                            ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
                            : 'From',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('date-to-button'),
                      onPressed: () => _pickDate(isFrom: false),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _dateTo != null
                            ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                            : 'To',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount Range
              Text('Amount Range', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('amount-min-field'),
                      controller: _amountMinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      key: const Key('amount-max-field'),
                      controller: _amountMaxController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Max',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Multi-select
              Text('Categories', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return _buildCategoryChips(state.categories);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('clear-filter-button'),
                      onPressed: _clearFilters,
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('apply-filter-button'),
                      onPressed: _applyFilters,
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips(List<Category> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categories.map((category) {
        final isSelected = _selectedCategoryIds.contains(category.uid);
        return FilterChip(
          key: Key('category-chip-${category.uid}'),
          label: Text(category.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategoryIds.add(category.uid);
              } else {
                _selectedCategoryIds.remove(category.uid);
              }
            });
          },
          avatar: CircleAvatar(
            backgroundColor: Color(category.color),
            radius: 8,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_dateFrom ?? now) : (_dateTo ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  void _clearFilters() {
    Navigator.of(context).pop(const ExpenseFilter());
  }

  void _applyFilters() {
    final amountMin = double.tryParse(_amountMinController.text);
    final amountMax = double.tryParse(_amountMaxController.text);

    final filter = ExpenseFilter(
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      categoryIds: _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
      amountMin: amountMin,
      amountMax: amountMax,
    );

    Navigator.of(context).pop(filter);
  }
}
