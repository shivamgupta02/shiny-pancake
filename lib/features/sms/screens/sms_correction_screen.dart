import 'package:flutter/material.dart';

import '../../../data/models/detected_expense.dart';

/// Result returned from the correction screen to the caller.
class SmsCorrectionResult {
  final double amount;
  final String? merchant;
  final DateTime date;
  final bool learn;

  const SmsCorrectionResult({
    required this.amount,
    this.merchant,
    required this.date,
    required this.learn,
  });
}

class SmsCorrectionScreen extends StatefulWidget {
  const SmsCorrectionScreen({
    super.key,
    required this.expense,
  });

  final DetectedExpense expense;

  @override
  State<SmsCorrectionScreen> createState() => _SmsCorrectionScreenState();
}

class _SmsCorrectionScreenState extends State<SmsCorrectionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late DateTime _selectedDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _merchantController = TextEditingController(
      text: widget.expense.merchant ?? '',
    );
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Correct Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender info
              if (widget.expense.sender != null &&
                  widget.expense.sender!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'From: ${widget.expense.sender}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

              // Raw SMS display
              Text(
                'Original SMS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  widget.expense.rawSmsBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = double.tryParse(value.replaceAll(',', ''));
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Merchant field
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant / Description',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Date picker
              _DatePickerField(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _onSave(learn: true),
                  icon: const Icon(Icons.psychology),
                  label: const Text('Save & Learn'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _onSave(learn: false),
                  child: const Text('Save Without Learning'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave({required bool learn}) {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.parse(_amountController.text.replaceAll(',', ''));
    final merchant = _merchantController.text.trim();

    Navigator.of(context).pop(
      SmsCorrectionResult(
        amount: amount,
        merchant: merchant.isEmpty ? null : merchant,
        date: _selectedDate,
        learn: learn,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.selectedDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          dateStr,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }
}
