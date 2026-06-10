import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ComparisonCard extends StatelessWidget {
  final double currentTotal;
  final double previousTotal;
  final double? percentageChange;
  final bool isFirstPeriod;
  final String periodLabel; // "week" or "month"
  final double averageDaily;

  const ComparisonCard({
    super.key,
    required this.currentTotal,
    required this.previousTotal,
    required this.percentageChange,
    required this.isFirstPeriod,
    required this.periodLabel,
    required this.averageDaily,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Spent',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(currentTotal),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(theme),
            const SizedBox(height: 8),
            _buildAverageDailyRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(ThemeData theme) {
    final (text, color, icon) = _getComparisonDisplay();

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'vs previous $periodLabel',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  (String, Color, IconData) _getComparisonDisplay() {
    // First period: neutral
    if (isFirstPeriod) {
      return ('0% — First $periodLabel', AppColors.neutral, Icons.remove);
    }

    // Both zero: no expenses
    if (currentTotal == 0 && previousTotal == 0) {
      return ('No expenses', AppColors.neutral, Icons.remove);
    }

    // Previous is 0, current > 0: "New"
    if (percentageChange == null) {
      return ('New', AppColors.neutral, Icons.fiber_new);
    }

    final change = percentageChange!;

    // Current is 0, previous exists: -100%
    if (currentTotal == 0 && previousTotal > 0) {
      return (
        '-100%',
        AppColors.decrease,
        Icons.arrow_downward,
      );
    }

    // Normal comparison
    if (change > 0) {
      return (
        '+${change.toStringAsFixed(1)}%',
        AppColors.increase,
        Icons.arrow_upward,
      );
    } else if (change < 0) {
      return (
        '${change.toStringAsFixed(1)}%',
        AppColors.decrease,
        Icons.arrow_downward,
      );
    } else {
      return ('0%', AppColors.neutral, Icons.remove);
    }
  }

  Widget _buildAverageDailyRow(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Avg daily: ${CurrencyFormatter.format(averageDaily)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
