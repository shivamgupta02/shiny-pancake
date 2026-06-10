enum ExpenseSource {
  manual,
  sms,
}

class Expense {
  final String uid;
  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final ExpenseSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.uid,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.create({
    required String uid,
    required double amount,
    required String categoryId,
    String? description,
    required DateTime date,
    required ExpenseSource source,
  }) {
    final now = DateTime.now();
    return Expense(
      uid: uid,
      amount: amount,
      categoryId: categoryId,
      description: description?.trim(),
      date: date,
      source: source,
      createdAt: now,
      updatedAt: now,
    );
  }

  Expense copyWith({
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
  }) {
    return Expense(
      uid: uid,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      source: source,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'source': source.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Expense.fromMap(Map<dynamic, dynamic> map) {
    return Expense(
      uid: map['uid'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      description: map['description'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      source: ExpenseSource.values[map['source'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'date': date.toIso8601String(),
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      uid: json['uid'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      source: ExpenseSource.values.byName(json['source'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
