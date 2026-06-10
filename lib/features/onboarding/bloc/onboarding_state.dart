import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingStep extends OnboardingState {
  const OnboardingStep({required this.currentStep, this.userName = ''});

  final int currentStep;
  final String userName;

  @override
  List<Object?> get props => [currentStep, userName];
}

class OnboardingError extends OnboardingState {
  const OnboardingError({required this.message, required this.currentStep});

  final String message;
  final int currentStep;

  @override
  List<Object?> get props => [message, currentStep];
}

class OnboardingComplete extends OnboardingState {
  const OnboardingComplete();
}
