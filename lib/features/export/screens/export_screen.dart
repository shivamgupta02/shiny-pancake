import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  late final ExportBloc _exportBloc;

  // Excel section state
  DateTime _excelDateFrom = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _excelDateTo = DateTime.now();
  List<String>? _selectedCategoryIds;
  List<Category> _categories = [];

  // PDF section state
  DateTime _pdfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _exportBloc = ExportBloc();
    _loadCategories();
  }

  @override
  void dispose() {
    _exportBloc.close();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await getIt<CategoryRepository>().getAll();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _excelDateFrom,
      firstDate: DateTime(2020),
      lastDate: _excelDateTo,
    );
    if (picked != null) {
      setState(() {
        _excelDateFrom = picked;
      });
    }
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _excelDateTo,
      firstDate: _excelDateFrom,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _excelDateTo = picked;
      });
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pdfMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _pdfMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _CategoryFilterSheet(
          categories: _categories,
          selectedIds: _selectedCategoryIds,
          onApply: (ids) {
            setState(() {
              _selectedCategoryIds = ids;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _exportExcel() {
    _exportBloc.add(ExportToExcel(
      dateFrom: _excelDateFrom,
      dateTo: _excelDateTo,
      categoryIds: _selectedCategoryIds,
    ));
  }

  void _exportPdf() {
    _exportBloc.add(ExportToPdf(month: _pdfMonth));
  }

  void _shareFile(String filePath) {
    _exportBloc.add(ShareExportedFile(filePath: filePath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _exportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export'),
        ),
        body: BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildExcelSection(context, state),
                  const SizedBox(height: 24),
                  _buildPdfSection(context, state),
                  const SizedBox(height: 24),
                  _buildStateIndicator(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExcelSection(BuildContext context, ExportState state) {
    final theme = Theme.of(context);
    final isExporting = state is ExportInProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Export Data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Export expenses as Excel spreadsheet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'From',
                    date: _excelDateFrom,
                    onTap: _pickDateFrom,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'To',
                    date: _excelDateTo,
                    onTap: _pickDateTo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category filter
            OutlinedButton.icon(
              onPressed: _showCategoryFilter,
              icon: const Icon(Icons.filter_list, size: 18),
              label: Text(
                _selectedCategoryIds == null || _selectedCategoryIds!.isEmpty
                    ? 'All Categories'
                    : '${_selectedCategoryIds!.length} categories selected',
              ),
            ),
            const SizedBox(height: 16),

            // Export button
            FilledButton.icon(
              onPressed: isExporting ? null : _exportExcel,
              icon: const Icon(Icons.download),
              label: const Text('Export to Excel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfSection(BuildContext context, ExportState state) {
    final theme = Theme.of(context);
    final isExporting = state is ExportInProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Export Report',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Generate monthly expense report as PDF',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Month picker
            _DatePickerField(
              label: 'Month',
              date: _pdfMonth,
              onTap: _pickMonth,
              displayText: DateFormatter.formatMonthYear(_pdfMonth),
            ),
            const SizedBox(height: 16),

            // Export button
            FilledButton.icon(
              onPressed: isExporting ? null : _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export as PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateIndicator(BuildContext context, ExportState state) {
    final theme = Theme.of(context);

    if (state is ExportInProgress) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(state.message, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (state is ExportSuccess) {
      return Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File generated successfully!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _shareFile(state.filePath),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ExportError) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final String? displayText;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          displayText ?? DateFormatter.formatFull(date),
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _CategoryFilterSheet extends StatefulWidget {
  final List<Category> categories;
  final List<String>? selectedIds;
  final ValueChanged<List<String>?> onApply;

  const _CategoryFilterSheet({
    required this.categories,
    required this.selectedIds,
    required this.onApply,
  });

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selected.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final isSelected = _selected.contains(category.uid);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(category.name),
                  dense: true,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selected.add(category.uid);
                      } else {
                        _selected.remove(category.uid);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              widget.onApply(
                _selected.isEmpty ? null : _selected.toList(),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
