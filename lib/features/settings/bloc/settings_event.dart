import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ChangeTheme extends SettingsEvent {
  const ChangeTheme(this.mode);

  final int mode;

  @override
  List<Object?> get props => [mode];
}

class ChangeTimeout extends SettingsEvent {
  const ChangeTimeout(this.minutes);

  final int minutes;

  @override
  List<Object?> get props => [minutes];
}

class ToggleBiometric extends SettingsEvent {
  const ToggleBiometric(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class CreateBackup extends SettingsEvent {
  const CreateBackup();
}

class RestoreBackup extends SettingsEvent {
  const RestoreBackup(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class ChangePin extends SettingsEvent {
  const ChangePin();
}
