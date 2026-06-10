import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/expense.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/daily_trend_chart.dart';
import '../widgets/summary_card.dart';
import '../widgets/top_categories_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(const LoadDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              key: Key('dashboard-loading'),
              child: CircularProgressIndicator(),
            );
          }

          if (state is DashboardError) {
            return _buildErrorState(context, state);
          }

          if (state is DashboardLoaded) {
            return _buildLoadedState(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DashboardError state) {
    final theme = Theme.of(context);
    return Center(
      key: const Key('dashboard-error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('dashboard-retry-button'),
              onPressed: () {
                context.read<DashboardBloc>().add(const LoadDashboard());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      key: const Key('dashboard-refresh-indicator'),
      onRefresh: () async {
        context
            .read<DashboardBloc>()
            .add(LoadDashboard(month: state.selectedMonth));
      },
      child: ListView(
        key: const Key('dashboard-content-list'),
        padding: const EdgeInsets.all(16),
        children: [
          _MonthSelector(
            key: const Key('dashboard-month-selector'),
            selectedMonth: state.selectedMonth,
          ),
          const SizedBox(height: 16),
          SummaryCard(
            monthTotal: state.monthTotal,
            percentageChange: state.percentageChange,
            isFirstMonth: state.isFirstMonth,
          ),
          const SizedBox(height: 16),
          CategoryPieChart(
            categoryBreakdown: state.categoryBreakdown,
          ),
          const SizedBox(height: 16),
          DailyTrendChart(
            dailyTotals: state.dailyTotals,
            averageDaily: state.averageDaily,
          ),
          const SizedBox(height: 16),
          TopCategoriesList(
            topCategories: state.topCategories,
            monthTotal: state.monthTotal,
          ),
          const SizedBox(height: 16),
          _RecentTransactions(
            key: const Key('dashboard-recent-transactions'),
            expenses: state.recentExpenses,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    super.key,
    required this.selectedMonth,
  });

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final canGoForward = selectedMonth.year < now.year ||
        (selectedMonth.year == now.year && selectedMonth.month < now.month);

    // Can navigate up to 2 years back
    final earliestMonth =
        DateTime(now.year - 2, now.month, 1);
    final canGoBack = selectedMonth.isAfter(earliestMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('dashboard-month-back'),
          onPressed: canGoBack
              ? () {
                  final previous = DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                    1,
                  );
                  context
                      .read<DashboardBloc>()
                      .add(ChangeMonth(month: previous));
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormatter.formatMonthYear(selectedMonth),
          key: const Key('dashboard-month-label'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('dashboard-month-forward'),
          onPressed: canGoForward
              ? () {
                  final next = DateTime(
                    selectedMonth.year,
                    selectedMonth.month + 1,
                    1,
                  );
                  context.read<DashboardBloc>().add(ChangeMonth(month: next));
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      key: const Key('dashboard-recent-transactions-card'),
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
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...expenses.asMap().entries.map((entry) {
              return _buildTransactionRow(context, entry.value, entry.key);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(
    BuildContext context,
    Expense expense,
    int index,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        key: Key('dashboard-recent-tx-$index'),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description?.isNotEmpty == true
                      ? expense.description!
                      : 'Expense',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatFull(expense.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
