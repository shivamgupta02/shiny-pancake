enum DetectionStatus {
  pending,
  confirmed,
  dismissed,
}

class DetectedExpense {
  final double amount;
  final String? merchant;
  final DateTime date;
  final String rawSmsBody;
  final DateTime smsDate;
  final double confidence;
  final DetectionStatus status;
  final String? sender;

  const DetectedExpense({
    required this.amount,
    this.merchant,
    required this.date,
    required this.rawSmsBody,
    required this.smsDate,
    required this.confidence,
    this.status = DetectionStatus.pending,
    this.sender,
  });

  DetectedExpense copyWith({
    double? amount,
    String? merchant,
    DateTime? date,
    String? rawSmsBody,
    DateTime? smsDate,
    double? confidence,
    DetectionStatus? status,
    String? sender,
  }) {
    return DetectedExpense(
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      rawSmsBody: rawSmsBody ?? this.rawSmsBody,
      smsDate: smsDate ?? this.smsDate,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      sender: sender ?? this.sender,
    );
  }
}
