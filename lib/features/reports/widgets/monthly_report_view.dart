import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../features/categories/widgets/category_picker.dart';
import '../bloc/report_state.dart';
import 'comparison_card.dart';

class MonthlyReportView extends StatelessWidget {
  final MonthlyReportLoaded state;

  const MonthlyReportView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ComparisonCard(
          currentTotal: state.totalSpent,
          previousTotal: state.previousMonthTotal,
          percentageChange: state.percentageChange,
          isFirstPeriod: state.isFirstMonth,
          periodLabel: 'month',
          averageDaily: state.averageDaily,
        ),
        const SizedBox(height: 16),
        _buildDailyTrendChart(context),
        const SizedBox(height: 16),
        _buildTopCategories(context),
        const SizedBox(height: 16),
        _buildFullCategoryBreakdown(context),
      ],
    );
  }

  Widget _buildDailyTrendChart(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = state.dailyTotals.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue > 0 ? maxValue * 1.2 : 100.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Trend',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Day ${group.x + 1}\n${CurrencyFormatter.format(rod.toY)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt() + 1;
                          // Show every 5th day and the 1st
                          if (day == 1 || day % 5 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '$day',
                                style: theme.textTheme.labelSmall,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                  ),
                  barGroups: List.generate(state.daysInMonth, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: state.dailyTotals[index],
                          color: theme.colorScheme.primary,
                          width: state.daysInMonth > 28 ? 6 : 8,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(BuildContext context) {
    final theme = Theme.of(context);

    if (state.topCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 5 Categories',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...state.topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _TopCategoryRow(
                rank: index + 1,
                item: item,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCategoryBreakdown(BuildContext context) {
    final theme = Theme.of(context);

    if (state.categoryBreakdown.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No expenses this month',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Categories',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...state.categoryBreakdown.map(
              (item) => _CategoryRow(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCategoryRow extends StatelessWidget {
  final int rank;
  final CategoryBreakdownItem item;

  const _TopCategoryRow({required this.rank, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(item.category.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '#$rank',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: categoryColor,
            radius: 14,
            child: Icon(
              _getIconData(item.category.icon),
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.category.name,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.total),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    return CategoryPicker.iconMap[iconName] ?? Icons.category;
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryBreakdownItem item;

  const _CategoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(item.category.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: categoryColor,
            radius: 14,
            child: Icon(
              _getIconData(item.category.icon),
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.category.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      CurrencyFormatter.format(item.total),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: item.percentage / 100,
                          backgroundColor:
                              categoryColor.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(categoryColor),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${item.percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    return CategoryPicker.iconMap[iconName] ?? Icons.category;
  }
}
