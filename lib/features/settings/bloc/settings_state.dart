import 'package:equatable/equatable.dart';

import '../../../data/models/app_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({required this.settings, this.lastBackupInfo});

  final AppSettings settings;
  final String? lastBackupInfo;

  @override
  List<Object?> get props => [settings, lastBackupInfo];
}

class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class BackupInProgress extends SettingsState {
  const BackupInProgress();
}

class BackupSuccess extends SettingsState {
  const BackupSuccess(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class RestoreSuccess extends SettingsState {
  const RestoreSuccess();
}
