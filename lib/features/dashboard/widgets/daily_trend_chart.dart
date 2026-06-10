import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../bloc/dashboard_state.dart';

class DailyTrendChart extends StatelessWidget {
  const DailyTrendChart({
    super.key,
    required this.dailyTotals,
    required this.averageDaily,
  });

  final List<DailyTotal> dailyTotals;
  final double averageDaily;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (dailyTotals.isEmpty || dailyTotals.every((d) => d.amount == 0)) {
      return Card(
        key: const Key('dashboard-trend-chart-empty'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No spending data this month',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final maxAmount =
        dailyTotals.map((d) => d.amount).reduce((a, b) => a > b ? a : b);

    return Card(
      key: const Key('dashboard-trend-chart-card'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Spending',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Avg: ${CurrencyFormatter.formatCompact(averageDaily)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.2,
                  barGroups: _buildBarGroups(theme),
                  titlesData: _buildTitlesData(theme),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxAmount > 0 ? maxAmount / 4 : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: averageDaily,
                        color: AppColors.primary.withValues(alpha: 0.7),
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: false,
                        ),
                      ),
                    ],
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Day ${group.x + 1}\n${CurrencyFormatter.formatCompact(rod.toY)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    return dailyTotals.map((daily) {
      return BarChartGroupData(
        x: daily.day - 1,
        barRods: [
          BarChartRodData(
            toY: daily.amount,
            color: daily.amount > averageDaily
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.5),
            width: dailyTotals.length > 20 ? 6 : 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData _buildTitlesData(ThemeData theme) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                CurrencyFormatter.formatCompact(value),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          getTitlesWidget: (value, meta) {
            final day = value.toInt() + 1;
            // Show every 5th day label to avoid crowding
            if (day == 1 || day % 5 == 0 || day == dailyTotals.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '$day',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
