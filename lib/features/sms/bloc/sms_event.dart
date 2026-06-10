import 'package:equatable/equatable.dart';

import '../../../data/models/detected_expense.dart';

abstract class SmsEvent extends Equatable {
  const SmsEvent();

  @override
  List<Object?> get props => [];
}

class RequestPermission extends SmsEvent {
  const RequestPermission();
}

class ScanMessages extends SmsEvent {
  const ScanMessages({required this.days});

  final int days;

  @override
  List<Object?> get props => [days];
}

class ConfirmExpense extends SmsEvent {
  const ConfirmExpense({
    required this.detectedExpense,
    required this.categoryId,
  });

  final DetectedExpense detectedExpense;
  final String categoryId;

  @override
  List<Object?> get props => [detectedExpense, categoryId];
}

class DismissExpense extends SmsEvent {
  const DismissExpense({required this.detectedExpense});

  final DetectedExpense detectedExpense;

  @override
  List<Object?> get props => [detectedExpense];
}

class CorrectAndConfirmExpense extends SmsEvent {
  const CorrectAndConfirmExpense({
    required this.detectedExpense,
    required this.correctAmount,
    this.correctMerchant,
    required this.correctDate,
    required this.categoryId,
    required this.sender,
    this.learn = true,
  });

  final DetectedExpense detectedExpense;
  final double correctAmount;
  final String? correctMerchant;
  final DateTime correctDate;
  final String categoryId;
  final String sender;
  final bool learn;

  @override
  List<Object?> get props => [
        detectedExpense,
        correctAmount,
        correctMerchant,
        correctDate,
        categoryId,
        sender,
        learn,
      ];
}
