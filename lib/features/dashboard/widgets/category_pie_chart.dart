import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../bloc/dashboard_state.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
    required this.categoryBreakdown,
  });

  final List<CategoryBreakdownItem> categoryBreakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryBreakdown.isEmpty) {
      return Card(
        key: const Key('dashboard-pie-chart-empty'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No expenses this month',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      key: const Key('dashboard-pie-chart-card'),
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
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _buildSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLegend(theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return categoryBreakdown.map((item) {
      return PieChartSectionData(
        value: item.amount,
        color: Color(item.categoryColor),
        radius: 28,
        showTitle: false,
      );
    }).toList();
  }

  Widget _buildLegend(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: categoryBreakdown.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(item.categoryColor),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.categoryName,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
