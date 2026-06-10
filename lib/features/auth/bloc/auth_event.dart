import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class VerifyPin extends AuthEvent {
  const VerifyPin(this.pin);

  final String pin;

  @override
  List<Object?> get props => [pin];
}

class AuthenticateBiometric extends AuthEvent {
  const AuthenticateBiometric();
}

class SetupPin extends AuthEvent {
  const SetupPin({required this.pin, required this.confirmPin});

  final String pin;
  final String confirmPin;

  @override
  List<Object?> get props => [pin, confirmPin];
}

class ChangePin extends AuthEvent {
  const ChangePin({
    required this.currentPin,
    required this.newPin,
    required this.confirmNewPin,
  });

  final String currentPin;
  final String newPin;
  final String confirmNewPin;

  @override
  List<Object?> get props => [currentPin, newPin, confirmNewPin];
}

class CheckLockStatus extends AuthEvent {
  const CheckLockStatus();
}

class ResetLock extends AuthEvent {
  const ResetLock();
}
