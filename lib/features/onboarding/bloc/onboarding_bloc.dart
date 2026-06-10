import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../services/secure_storage_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingStep(currentStep: 0)) {
    _settingsRepository = getIt<SettingsRepository>();
    _secureStorage = getIt<SecureStorageService>();

    on<SetName>(_onSetName);
    on<SetupPin>(_onSetupPin);
    on<RequestSmsPermission>(_onRequestSmsPermission);
    on<SkipSmsPermission>(_onSkipSmsPermission);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  late final SettingsRepository _settingsRepository;
  late final SecureStorageService _secureStorage;

  String _userName = '';

  Future<void> _onSetName(SetName event, Emitter<OnboardingState> emit) async {
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(const OnboardingError(
        message: 'Please enter your name',
        currentStep: 1,
      ));
      return;
    }

    _userName = name;
    final settings = await _settingsRepository.getSettings();
    settings.userName = name;
    await _settingsRepository.updateSettings(settings);

    emit(OnboardingStep(currentStep: 2, userName: _userName));
  }

  Future<void> _onSetupPin(
    SetupPin event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event.pin.length != AppConstants.pinLength) {
      emit(OnboardingError(
        message: 'PIN must be ${AppConstants.pinLength} digits',
        currentStep: 2,
      ));
      return;
    }

    if (event.pin != event.confirmPin) {
      emit(const OnboardingError(
        message: 'PINs do not match',
        currentStep: 2,
      ));
      return;
    }

    final hash = _secureStorage.hashPin(event.pin);
    await _secureStorage.storePin(hash);

    emit(OnboardingStep(currentStep: 3, userName: _userName));
  }

  Future<void> _onRequestSmsPermission(
    RequestSmsPermission event,
    Emitter<OnboardingState> emit,
  ) async {
    final settings = await _settingsRepository.getSettings();
    settings.smsEnabled = true;
    await _settingsRepository.updateSettings(settings);

    emit(OnboardingStep(currentStep: 4, userName: _userName));
  }

  Future<void> _onSkipSmsPermission(
    SkipSmsPermission event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingStep(currentStep: 4, userName: _userName));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    await _settingsRepository.setOnboardingComplete();
    emit(const OnboardingComplete());
  }
}
