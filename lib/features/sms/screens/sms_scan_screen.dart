import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/detected_expense.dart';
import '../../categories/widgets/category_picker.dart';
import '../bloc/sms_bloc.dart';
import '../bloc/sms_event.dart';
import '../bloc/sms_state.dart';
import 'learned_rules_screen.dart';
import 'sms_correction_screen.dart';

class SmsScanScreen extends StatelessWidget {
  const SmsScanScreen({super.key, this.scanPending = false});

  final bool scanPending;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = SmsBloc();
        if (scanPending) {
          bloc.add(const ScanPendingMessages());
        }
        return bloc;
      },
      child: const _SmsScanView(),
    );
  }
}

class _SmsScanView extends StatelessWidget {
  const _SmsScanView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Detection'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LearnedRulesScreen(),
              ),
            ),
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Learned Rules',
          ),
        ],
      ),
      body: BlocBuilder<SmsBloc, SmsState>(
        builder: (context, state) {
          if (state is SmsInitial) {
            return _buildScanOptions(context, theme);
          }
          if (state is SmsPermissionDenied) {
            return _buildPermissionRequest(context, theme);
          }
          if (state is SmsScanning) {
            return _buildScanning(theme);
          }
          if (state is SmsLoaded) {
            return _buildLoaded(context, theme, state);
          }
          if (state is SmsError) {
            return _buildError(context, theme, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScanOptions(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sms_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan SMS for Expenses',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Automatically detect expenses from your bank SMS alerts.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context
                  .read<SmsBloc>()
                  .add(const ScanMessages(days: 1)),
              icon: const Icon(Icons.today),
              label: const Text('Scan Today'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<SmsBloc>()
                  .add(const ScanMessages(days: 7)),
              icon: const Icon(Icons.search),
              label: const Text('Scan Last 7 Days'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<SmsBloc>()
                  .add(const ScanMessages(days: 30)),
              icon: const Icon(Icons.search),
              label: const Text('Scan Last 30 Days'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequest(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sms_failed_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'SMS Permission Required',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'To detect expenses from bank alerts, we need permission to read your SMS messages.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context
                  .read<SmsBloc>()
                  .add(const RequestPermission()),
              icon: const Icon(Icons.lock_open),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanning(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Scanning messages...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Looking for bank debit alerts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, ThemeData theme, SmsLoaded state) {
    final totalDetected = state.detectedExpenses.length +
        state.confirmedCount +
        state.dismissedCount;

    return Column(
      children: [
        // Summary bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Text(
            '$totalDetected detected • ${state.confirmedCount} confirmed • ${state.dismissedCount} dismissed',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // List or empty state
        Expanded(
          child: state.detectedExpenses.isEmpty
              ? _buildEmptyState(context, theme)
              : _buildExpenseList(context, theme, state.detectedExpenses),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'All done!',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No more expenses to review.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<SmsBloc>()
                  .add(const ScanMessages(days: 7)),
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(
    BuildContext context,
    ThemeData theme,
    List<DetectedExpense> expenses,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _DetectedExpenseCard(expense: expenses[index]);
      },
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, SmsError state) {
    return Center(
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
              style: theme.textTheme.titleLarge,
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
              onPressed: () => context
                  .read<SmsBloc>()
                  .add(const ScanMessages(days: 7)),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectedExpenseCard extends StatelessWidget {
  const _DetectedExpenseCard({required this.expense});

  final DetectedExpense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount and confidence badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(expense.amount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _ConfidenceBadge(confidence: expense.confidence),
              ],
            ),
            const SizedBox(height: 8),
            // Merchant
            if (expense.merchant != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        expense.merchant!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatFull(expense.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _onDismiss(context),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _onEdit(context),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _onConfirm(context),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirm(BuildContext context) async {
    final category = await CategoryPicker.show(context);
    if (category == null || !context.mounted) return;

    context.read<SmsBloc>().add(ConfirmExpense(
      detectedExpense: expense,
      categoryId: category.uid,
    ));
  }

  void _onEdit(BuildContext context) async {
    final result = await Navigator.of(context).push<SmsCorrectionResult>(
      MaterialPageRoute(
        builder: (_) => SmsCorrectionScreen(expense: expense),
      ),
    );

    if (result == null || !context.mounted) return;

    // Pick a category after correction
    final category = await CategoryPicker.show(context);
    if (category == null || !context.mounted) return;

    context.read<SmsBloc>().add(CorrectAndConfirmExpense(
      detectedExpense: expense,
      correctAmount: result.amount,
      correctMerchant: result.merchant,
      correctDate: result.date,
      categoryId: category.uid,
      sender: expense.sender ?? '',
      learn: result.learn,
    ));
  }

  void _onDismiss(BuildContext context) {
    context.read<SmsBloc>().add(DismissExpense(detectedExpense: expense));
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isHigh = confidence >= 0.7;
    final label = isHigh ? 'High' : 'Review';
    final color = isHigh
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
