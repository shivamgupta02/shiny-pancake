import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/sms_rule.dart';
import '../../../services/sms_rule_service.dart';

class LearnedRulesScreen extends StatefulWidget {
  const LearnedRulesScreen({super.key});

  @override
  State<LearnedRulesScreen> createState() => _LearnedRulesScreenState();
}

class _LearnedRulesScreenState extends State<LearnedRulesScreen> {
  final SmsRuleService _smsRuleService = getIt<SmsRuleService>();
  List<SmsRule> _rules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final rules = await _smsRuleService.getAllRules();
    if (mounted) {
      setState(() {
        _rules = rules;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learned Rules'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rules.isEmpty
              ? _buildEmpty(theme)
              : _buildList(theme),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Learned Rules',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'When you correct a detected expense, the app will learn '
              'how to parse similar messages in the future.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final rule = _rules[index];
        return _LearnedRuleCard(
          rule: rule,
          onDelete: () => _deleteRule(rule),
        );
      },
    );
  }

  Future<void> _deleteRule(SmsRule rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text(
          'Delete the learned rule for sender "${rule.sender}"? '
          'Future messages from this sender will use generic parsing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _smsRuleService.deleteRule(rule.sender);
      await _loadRules();
    }
  }
}

class _LearnedRuleCard extends StatelessWidget {
  const _LearnedRuleCard({
    required this.rule,
    required this.onDelete,
  });

  final SmsRule rule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdStr =
        '${rule.createdAt.day}/${rule.createdAt.month}/${rule.createdAt.year}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rule.sender,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  tooltip: 'Delete rule',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Sample message preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rule.sampleBody.length > 100
                    ? '${rule.sampleBody.substring(0, 100)}...'
                    : rule.sampleBody,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${rule.successCount} successful parses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'Created $createdStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
