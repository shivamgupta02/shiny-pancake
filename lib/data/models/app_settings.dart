class AppSettings {
  String userName;
  int themeMode; // 0=system, 1=light, 2=dark
  int timeoutMinutes;
  bool biometricEnabled;
  bool onboardingComplete;
  bool smsEnabled;
  DateTime? lastBackupDate;

  AppSettings({
    required this.userName,
    required this.themeMode,
    required this.timeoutMinutes,
    required this.biometricEnabled,
    required this.onboardingComplete,
    required this.smsEnabled,
    this.lastBackupDate,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      userName: '',
      themeMode: 0,
      timeoutMinutes: 1,
      biometricEnabled: false,
      onboardingComplete: false,
      smsEnabled: false,
      lastBackupDate: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'themeMode': themeMode,
      'timeoutMinutes': timeoutMinutes,
      'biometricEnabled': biometricEnabled,
      'onboardingComplete': onboardingComplete,
      'smsEnabled': smsEnabled,
      'lastBackupDate': lastBackupDate?.millisecondsSinceEpoch,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      userName: map['userName'] as String? ?? '',
      themeMode: map['themeMode'] as int? ?? 0,
      timeoutMinutes: map['timeoutMinutes'] as int? ?? 1,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      smsEnabled: map['smsEnabled'] as bool? ?? false,
      lastBackupDate: map['lastBackupDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastBackupDate'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'themeMode': themeMode,
      'timeoutMinutes': timeoutMinutes,
      'biometricEnabled': biometricEnabled,
      'onboardingComplete': onboardingComplete,
      'smsEnabled': smsEnabled,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userName: json['userName'] as String? ?? '',
      themeMode: json['themeMode'] as int? ?? 0,
      timeoutMinutes: json['timeoutMinutes'] as int? ?? 1,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
    );
  }
}
