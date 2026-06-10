import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLocked extends AuthState {
  const AuthLocked({this.remainingAttempts});

  final int? remainingAttempts;

  @override
  List<Object?> get props => [remainingAttempts];
}

class AuthUnlocked extends AuthState {
  const AuthUnlocked();
}

class AuthPinSetupRequired extends AuthState {
  const AuthPinSetupRequired();
}

class AuthError extends AuthState {
  const AuthError(this.message, {this.remainingAttempts});

  final String message;
  final int? remainingAttempts;

  @override
  List<Object?> get props => [message, remainingAttempts];
}

class AuthLockout extends AuthState {
  const AuthLockout(this.remainingSeconds);

  final int remainingSeconds;

  @override
  List<Object?> get props => [remainingSeconds];
}

class PinSetupSuccess extends AuthState {
  const PinSetupSuccess();
}
