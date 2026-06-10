import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../categories/widgets/category_picker.dart';
import '../bloc/dashboard_state.dart';

class TopCategoriesList extends StatelessWidget {
  const TopCategoriesList({
    super.key,
    required this.topCategories,
    required this.monthTotal,
  });

  final List<CategoryBreakdownItem> topCategories;
  final double monthTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      key: const Key('dashboard-top-categories-card'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...topCategories.asMap().entries.map((entry) {
              return _buildCategoryRow(context, entry.value, entry.key);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    CategoryBreakdownItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final iconData =
        CategoryPicker.iconMap[item.categoryIcon] ?? Icons.category;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        key: Key('dashboard-top-category-$index'),
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(item.categoryColor).withValues(alpha: 0.15),
            child: Icon(
              iconData,
              size: 18,
              color: Color(item.categoryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.percentage / 100,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    color: Color(item.categoryColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(item.amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
