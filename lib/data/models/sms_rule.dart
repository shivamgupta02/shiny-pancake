class SmsRule {
  final String sender;
  final String? amountPattern;
  final String? merchantPattern;
  final String? datePattern;
  final String sampleBody;
  final DateTime createdAt;
  final int successCount;

  const SmsRule({
    required this.sender,
    this.amountPattern,
    this.merchantPattern,
    this.datePattern,
    required this.sampleBody,
    required this.createdAt,
    this.successCount = 0,
  });

  SmsRule copyWith({
    String? sender,
    String? amountPattern,
    String? merchantPattern,
    String? datePattern,
    String? sampleBody,
    DateTime? createdAt,
    int? successCount,
  }) {
    return SmsRule(
      sender: sender ?? this.sender,
      amountPattern: amountPattern ?? this.amountPattern,
      merchantPattern: merchantPattern ?? this.merchantPattern,
      datePattern: datePattern ?? this.datePattern,
      sampleBody: sampleBody ?? this.sampleBody,
      createdAt: createdAt ?? this.createdAt,
      successCount: successCount ?? this.successCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'amountPattern': amountPattern,
      'merchantPattern': merchantPattern,
      'datePattern': datePattern,
      'sampleBody': sampleBody,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'successCount': successCount,
    };
  }

  factory SmsRule.fromMap(Map<dynamic, dynamic> map) {
    return SmsRule(
      sender: map['sender'] as String,
      amountPattern: map['amountPattern'] as String?,
      merchantPattern: map['merchantPattern'] as String?,
      datePattern: map['datePattern'] as String?,
      sampleBody: map['sampleBody'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      successCount: (map['successCount'] as int?) ?? 0,
    );
  }
}
