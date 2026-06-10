import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_picker.dart';
import 'create_category_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc()..add(const LoadCategories()),
      child: const _CategoryListView(),
    );
  }
}

class _CategoryListView extends StatelessWidget {
  const _CategoryListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
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
                      context.read<CategoryBloc>().add(const LoadCategories());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryLoaded) {
            return _buildCategoryList(context, state.categories);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-category-fab'),
        onPressed: () => _navigateToCreate(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories) {
    final theme = Theme.of(context);

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No categories',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryTile(category: category);
      },
    );
  }

  void _navigateToCreate(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
    );
    if (result == true && context.mounted) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Category: ${category.name}${category.isDefault ? ', default' : ''}',
      child: ListTile(
        key: Key('category-tile-${category.uid}'),
        leading: CircleAvatar(
          backgroundColor: Color(category.color),
          child: Icon(
            CategoryPicker.iconMap[category.icon] ?? Icons.category,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(category.name),
        trailing: category.isDefault
            ? Icon(
                Icons.lock_outline,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : PopupMenuButton<String>(
                key: Key('category-menu-${category.uid}'),
                onSelected: (value) => _onMenuAction(context, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _onMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _navigateToEdit(context);
      case 'delete':
        _showDeleteDialog(context);
    }
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateCategoryScreen(category: category),
      ),
    );
    if (result == true && context.mounted) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final categoryRepo = getIt<CategoryRepository>();
    final expenseCount = await categoryRepo.getExpenseCount(category.uid);
    final allCategories = await categoryRepo.getAll();
    final defaultCategories = allCategories.where((c) => c.isDefault).toList();

    if (!context.mounted) return;

    Category? reassignTo;
    if (defaultCategories.isNotEmpty) {
      reassignTo = defaultCategories.first;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category.name}"?'),
            if (expenseCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$expenseCount expense(s) will be reassigned to "${reassignTo?.name ?? "Other"}".',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            key: const Key('cancel-delete-category-button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm-delete-category-button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted && reassignTo != null) {
      context.read<CategoryBloc>().add(DeleteCategory(
        uid: category.uid,
        reassignToId: reassignTo.uid,
      ));
    }
  }
}
