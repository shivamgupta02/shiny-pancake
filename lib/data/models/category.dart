class Category {
  final String uid;
  final String name;
  final String icon;
  final int color;
  final bool isDefault;
  final DateTime createdAt;
  final int sortOrder;

  Category({
    required this.uid,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.createdAt,
    required this.sortOrder,
  });

  factory Category.create({
    required String uid,
    required String name,
    required String icon,
    required int color,
    required bool isDefault,
    required int sortOrder,
  }) {
    return Category(
      uid: uid,
      name: name,
      icon: icon,
      color: color,
      isDefault: isDefault,
      createdAt: DateTime.now(),
      sortOrder: sortOrder,
    );
  }

  Category copyWith({
    String? name,
    String? icon,
    int? color,
  }) {
    return Category(
      uid: uid,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault,
      createdAt: createdAt,
      sortOrder: sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'sortOrder': sortOrder,
    };
  }

  factory Category.fromMap(Map<dynamic, dynamic> map) {
    return Category(
      uid: map['uid'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as int,
      isDefault: map['isDefault'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      sortOrder: map['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      uid: json['uid'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      isDefault: json['isDefault'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sortOrder: json['sortOrder'] as int,
    );
  }
}
