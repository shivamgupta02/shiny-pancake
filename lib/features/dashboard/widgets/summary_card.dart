import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.monthTotal,
    required this.percentageChange,
    required this.isFirstMonth,
  });

  final double monthTotal;
  final double percentageChange;
  final bool isFirstMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const Key('dashboard-summary-card'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Spent',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(monthTotal),
              key: const Key('dashboard-month-total'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildComparison(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(ThemeData theme) {
    if (isFirstMonth) {
      return Row(
        key: const Key('dashboard-comparison-first-month'),
        children: [
          const Icon(
            Icons.trending_flat,
            size: 18,
            color: AppColors.neutral,
          ),
          const SizedBox(width: 4),
          Text(
            '0% — First month',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral,
            ),
          ),
        ],
      );
    }

    final isIncrease = percentageChange > 0;
    final isDecrease = percentageChange < 0;
    final color = isIncrease
        ? AppColors.increase
        : isDecrease
            ? AppColors.decrease
            : AppColors.neutral;
    final icon = isIncrease
        ? Icons.trending_up
        : isDecrease
            ? Icons.trending_down
            : Icons.trending_flat;
    final sign = isIncrease ? '+' : '';

    return Row(
      key: const Key('dashboard-comparison-row'),
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          '$sign${percentageChange.toStringAsFixed(1)}% vs last month',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
