import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class SetName extends OnboardingEvent {
  const SetName(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

class SetupPin extends OnboardingEvent {
  const SetupPin({required this.pin, required this.confirmPin});

  final String pin;
  final String confirmPin;

  @override
  List<Object?> get props => [pin, confirmPin];
}

class RequestSmsPermission extends OnboardingEvent {
  const RequestSmsPermission();
}

class SkipSmsPermission extends OnboardingEvent {
  const SkipSmsPermission();
}

class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}
