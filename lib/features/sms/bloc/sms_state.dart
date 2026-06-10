import 'package:equatable/equatable.dart';

import '../../../data/models/detected_expense.dart';

abstract class SmsState extends Equatable {
  const SmsState();

  @override
  List<Object?> get props => [];
}

class SmsInitial extends SmsState {
  const SmsInitial();
}

class SmsScanning extends SmsState {
  const SmsScanning();
}

class SmsLoaded extends SmsState {
  const SmsLoaded({
    required this.detectedExpenses,
    this.confirmedCount = 0,
    this.dismissedCount = 0,
  });

  final List<DetectedExpense> detectedExpenses;
  final int confirmedCount;
  final int dismissedCount;

  @override
  List<Object?> get props => [detectedExpenses, confirmedCount, dismissedCount];
}

class SmsPermissionDenied extends SmsState {
  const SmsPermissionDenied();
}

class SmsError extends SmsState {
  const SmsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
