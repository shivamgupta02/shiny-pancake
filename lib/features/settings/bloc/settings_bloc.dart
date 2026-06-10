import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../services/backup_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    _settingsRepository = getIt<SettingsRepository>();
    _backupService = getIt<BackupService>();

    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeTimeout>(_onChangeTimeout);
    on<ToggleBiometric>(_onToggleBiometric);
    on<CreateBackup>(_onCreateBackup);
    on<RestoreBackup>(_onRestoreBackup);
  }

  late final SettingsRepository _settingsRepository;
  late final BackupService _backupService;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings = await _settingsRepository.getSettings();
      final backupInfo = settings.lastBackupDate != null
          ? DateFormat.yMMMd().add_jm().format(settings.lastBackupDate!)
          : null;
      emit(SettingsLoaded(settings: settings, lastBackupInfo: backupInfo));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.updateTheme(event.mode);
      add(const LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeTimeout(
    ChangeTimeout event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.updateTimeout(event.minutes);
      add(const LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (event.enabled) {
        // Verify device supports biometrics before enabling
        final canCheck = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        if (!canCheck || !isDeviceSupported) {
          emit(const SettingsError(
            'Biometric authentication is not available on this device',
          ));
          add(const LoadSettings());
          return;
        }
      }

      await _settingsRepository.toggleBiometric(event.enabled);
      add(const LoadSettings());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onCreateBackup(
    CreateBackup event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const BackupInProgress());
      final filePath = await _backupService.createBackup();
      emit(BackupSuccess(filePath));
      add(const LoadSettings());
    } catch (e) {
      emit(SettingsError('Backup failed: ${e.toString()}'));
      add(const LoadSettings());
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackup event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const BackupInProgress());

      final isValid = await _backupService.validateBackup(event.filePath);
      if (!isValid) {
        emit(const SettingsError('Invalid backup file'));
        add(const LoadSettings());
        return;
      }

      await _backupService.restoreBackup(event.filePath);
      emit(const RestoreSuccess());
      add(const LoadSettings());
    } catch (e) {
      emit(SettingsError('Restore failed: ${e.toString()}'));
      add(const LoadSettings());
    }
  }
}
