import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/detected_expense.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../services/sms_parsing_service.dart';
import '../../../services/sms_reader_service.dart';
import '../../../services/sms_rule_service.dart';
import 'sms_event.dart';
import 'sms_state.dart';

class SmsBloc extends Bloc<SmsEvent, SmsState> {
  SmsBloc() : super(const SmsInitial()) {
    on<RequestPermission>(_onRequestPermission);
    on<ScanMessages>(_onScanMessages);
    on<ScanPendingMessages>(_onScanPendingMessages);
    on<ConfirmExpense>(_onConfirmExpense);
    on<DismissExpense>(_onDismissExpense);
    on<CorrectAndConfirmExpense>(_onCorrectAndConfirmExpense);
  }

  final SmsReaderService _smsReaderService = getIt<SmsReaderService>();
  final SmsParsingService _smsParsingService = getIt<SmsParsingService>();
  final ExpenseRepository _expenseRepository = getIt<ExpenseRepository>();
  final SmsRuleService _smsRuleService = getIt<SmsRuleService>();

  int _confirmedCount = 0;
  int _dismissedCount = 0;

  Future<void> _onRequestPermission(
    RequestPermission event,
    Emitter<SmsState> emit,
  ) async {
    try {
      final granted = await _smsReaderService.requestPermission();
      if (!granted) {
        emit(const SmsPermissionDenied());
      } else {
        emit(const SmsInitial());
      }
    } catch (e) {
      emit(SmsError(message: e.toString()));
    }
  }

  Future<void> _onScanMessages(
    ScanMessages event,
    Emitter<SmsState> emit,
  ) async {
    try {
      // Check permission first
      final hasPermission = await _smsReaderService.hasPermission();
      if (!hasPermission) {
        emit(const SmsPermissionDenied());
        return;
      }

      emit(const SmsScanning());

      // Reset counters on new scan
      _confirmedCount = 0;
      _dismissedCount = 0;

      final messages = await _smsReaderService.readMessages(event.days);

      // Load existing SMS-sourced expenses to deduplicate
      final existingExpenses = await _expenseRepository.getAll();
      final existingSet = <String>{};
      for (final e in existingExpenses) {
        if (e.source == ExpenseSource.sms) {
          // Key: amount + date (day precision) to detect duplicates
          existingSet.add('${e.amount}_${e.date.year}_${e.date.month}_${e.date.day}');
        }
      }

      final detectedExpenses = <DetectedExpense>[];

      for (final message in messages) {
        final body = message['body'] as String? ?? '';
        final dateMillis = message['date'] as int?;
        final sender = message['sender'] as String? ?? '';
        final smsDate = dateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(dateMillis)
            : DateTime.now();

        // Check for a learned rule for this sender
        final rule = await _smsRuleService.getRuleForSender(sender);

        final detected = _smsParsingService.parseMessage(
          body,
          smsDate: smsDate,
          rule: rule,
          sender: sender,
        );

        if (detected != null && detected.confidence >= 0.4) {
          // Skip if already added as expense
          final key = '${detected.amount}_${detected.date.year}_${detected.date.month}_${detected.date.day}';
          if (existingSet.contains(key)) continue;

          // If rule was used successfully, increment success count
          if (rule != null && detected.confidence >= 0.9) {
            await _smsRuleService.incrementSuccess(sender);
          }
          detectedExpenses.add(detected);
        }
      }

      // Sort by date descending (most recent first)
      detectedExpenses.sort((a, b) => b.smsDate.compareTo(a.smsDate));

      emit(SmsLoaded(
        detectedExpenses: detectedExpenses,
        confirmedCount: _confirmedCount,
        dismissedCount: _dismissedCount,
      ));
    } catch (e) {
      emit(SmsError(message: e.toString()));
    }
  }

  Future<void> _onScanPendingMessages(
    ScanPendingMessages event,
    Emitter<SmsState> emit,
  ) async {
    try {
      emit(const SmsScanning());

      _confirmedCount = 0;
      _dismissedCount = 0;

      // Read pending messages from BroadcastReceiver
      final pending = await _smsReaderService.getPendingMessages();
      await _smsReaderService.clearPendingMessages();

      final detectedExpenses = <DetectedExpense>[];

      for (final message in pending) {
        final body = message['body'] as String? ?? '';
        final dateMillis = message['date'] as int?;
        final sender = message['sender'] as String? ?? '';
        final smsDate = dateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(dateMillis)
            : DateTime.now();

        final rule = await _smsRuleService.getRuleForSender(sender);

        final detected = _smsParsingService.parseMessage(
          body,
          smsDate: smsDate,
          rule: rule,
          sender: sender,
        );

        if (detected != null && detected.confidence >= 0.4) {
          if (rule != null && detected.confidence >= 0.9) {
            await _smsRuleService.incrementSuccess(sender);
          }
          detectedExpenses.add(detected);
        }
      }

      detectedExpenses.sort((a, b) => b.smsDate.compareTo(a.smsDate));

      emit(SmsLoaded(
        detectedExpenses: detectedExpenses,
        confirmedCount: _confirmedCount,
        dismissedCount: _dismissedCount,
      ));
    } catch (e) {
      emit(SmsError(message: e.toString()));
    }
  }

  Future<void> _onConfirmExpense(
    ConfirmExpense event,
    Emitter<SmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! SmsLoaded) return;

      // Create the expense in repository
      await _expenseRepository.create(
        amount: event.detectedExpense.amount,
        categoryId: event.categoryId,
        description: event.detectedExpense.merchant,
        date: event.detectedExpense.date,
        source: ExpenseSource.sms,
      );

      _confirmedCount++;

      // Remove from list
      final updatedList = currentState.detectedExpenses
          .where((e) => e != event.detectedExpense)
          .toList();

      emit(SmsLoaded(
        detectedExpenses: updatedList,
        confirmedCount: _confirmedCount,
        dismissedCount: _dismissedCount,
      ));
    } catch (e) {
      emit(SmsError(message: e.toString()));
    }
  }

  Future<void> _onDismissExpense(
    DismissExpense event,
    Emitter<SmsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmsLoaded) return;

    _dismissedCount++;

    final updatedList = currentState.detectedExpenses
        .where((e) => e != event.detectedExpense)
        .toList();

    emit(SmsLoaded(
      detectedExpenses: updatedList,
      confirmedCount: _confirmedCount,
      dismissedCount: _dismissedCount,
    ));
  }

  Future<void> _onCorrectAndConfirmExpense(
    CorrectAndConfirmExpense event,
    Emitter<SmsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! SmsLoaded) return;

      // Learn from correction if requested
      if (event.learn) {
        final rule = _smsRuleService.learnFromCorrection(
          rawBody: event.detectedExpense.rawSmsBody,
          sender: event.sender,
          correctAmount: event.correctAmount,
          correctMerchant: event.correctMerchant,
          correctDate: event.correctDate,
        );

        if (rule != null) {
          await _smsRuleService.saveRule(rule);
        }
      }

      // Create the expense with corrected values
      await _expenseRepository.create(
        amount: event.correctAmount,
        categoryId: event.categoryId,
        description: event.correctMerchant,
        date: event.correctDate,
        source: ExpenseSource.sms,
      );

      _confirmedCount++;

      // Remove from list
      final updatedList = currentState.detectedExpenses
          .where((e) => e != event.detectedExpense)
          .toList();

      emit(SmsLoaded(
        detectedExpenses: updatedList,
        confirmedCount: _confirmedCount,
        dismissedCount: _dismissedCount,
      ));
    } catch (e) {
      emit(SmsError(message: e.toString()));
    }
  }
}
