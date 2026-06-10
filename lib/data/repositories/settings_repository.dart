import '../datasources/local_database.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._localDatabase);

  final LocalDatabase _localDatabase;

  Future<AppSettings> getSettings() async {
    return _localDatabase.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _localDatabase.updateSettings(settings);
  }

  Future<bool> isOnboardingComplete() async {
    final settings = await _localDatabase.getSettings();
    return settings.onboardingComplete;
  }

  Future<void> setOnboardingComplete() async {
    final settings = await _localDatabase.getSettings();
    settings.onboardingComplete = true;
    await _localDatabase.updateSettings(settings);
  }

  Future<void> updateTheme(int themeMode) async {
    final settings = await _localDatabase.getSettings();
    settings.themeMode = themeMode;
    await _localDatabase.updateSettings(settings);
  }

  Future<void> updateTimeout(int minutes) async {
    final settings = await _localDatabase.getSettings();
    settings.timeoutMinutes = minutes;
    await _localDatabase.updateSettings(settings);
  }

  Future<void> toggleBiometric(bool enabled) async {
    final settings = await _localDatabase.getSettings();
    settings.biometricEnabled = enabled;
    await _localDatabase.updateSettings(settings);
  }

  Future<void> toggleSms(bool enabled) async {
    final settings = await _localDatabase.getSettings();
    settings.smsEnabled = enabled;
    await _localDatabase.updateSettings(settings);
  }

  Future<void> updateLastBackupDate() async {
    final settings = await _localDatabase.getSettings();
    settings.lastBackupDate = DateTime.now();
    await _localDatabase.updateSettings(settings);
  }
}
