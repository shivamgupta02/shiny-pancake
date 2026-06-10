import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/date_formatter.dart';
import '../../export/screens/export_screen.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/monthly_report_view.dart';
import '../widgets/weekly_report_view.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ReportBloc _reportBloc;

  late DateTime _currentWeekStart;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reportBloc = ReportBloc();

    _currentWeekStart = DateFormatter.mondayOfWeek(DateTime.now());
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    _reportBloc.add(LoadWeeklyReport(_currentWeekStart));

    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _reportBloc.close();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _reportBloc.add(LoadWeeklyReport(_currentWeekStart));
    } else {
      _reportBloc.add(LoadMonthlyReport(_currentMonth));
    }
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = DateTime(
        _currentWeekStart.year,
        _currentWeekStart.month,
        _currentWeekStart.day - 7,
      );
    });
    _reportBloc.add(LoadWeeklyReport(_currentWeekStart));
  }

  void _nextWeek() {
    final nextWeek = DateTime(
      _currentWeekStart.year,
      _currentWeekStart.month,
      _currentWeekStart.day + 7,
    );
    final today = DateFormatter.mondayOfWeek(DateTime.now());
    if (nextWeek.isAfter(today)) return;
    setState(() {
      _currentWeekStart = nextWeek;
    });
    _reportBloc.add(LoadWeeklyReport(_currentWeekStart));
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _reportBloc.add(LoadMonthlyReport(_currentMonth));
  }

  void _nextMonth() {
    final nextMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      1,
    );
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    if (nextMonth.isAfter(currentMonthStart)) return;
    setState(() {
      _currentMonth = nextMonth;
    });
    _reportBloc.add(LoadMonthlyReport(_currentMonth));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reportBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          actions: [
            IconButton(
              key: const Key('export-button'),
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Export',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExportScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildPeriodSelector(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeeklyTab(),
                  _buildMonthlyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isWeekly = _tabController.index == 0;
        final label = isWeekly ? _weekRangeLabel() : _monthLabel();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('report-previous-button'),
                onPressed: isWeekly ? _previousWeek : _previousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                key: const Key('report-next-button'),
                onPressed: isWeekly ? _nextWeek : _nextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
    );
  }

  String _weekRangeLabel() {
    final weekEnd = DateTime(
      _currentWeekStart.year,
      _currentWeekStart.month,
      _currentWeekStart.day + 6,
    );
    return '${DateFormatter.formatDayMonth(_currentWeekStart)} – ${DateFormatter.formatDayMonth(weekEnd)}';
  }

  String _monthLabel() {
    return DateFormatter.formatMonthYear(_currentMonth);
  }

  Widget _buildWeeklyTab() {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WeeklyReportLoaded) {
          return WeeklyReportView(state: state);
        }
        if (state is ReportError) {
          return _buildErrorView(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMonthlyTab() {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MonthlyReportLoaded) {
          return MonthlyReportView(state: state);
        }
        if (state is ReportError) {
          return _buildErrorView(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorView(String message) {
    final theme = Theme.of(context);
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
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
