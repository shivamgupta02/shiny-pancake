import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../services/secure_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    _secureStorage = getIt<SecureStorageService>();
    _settingsRepository = getIt<SettingsRepository>();

    on<VerifyPin>(_onVerifyPin);
    on<AuthenticateBiometric>(_onAuthenticateBiometric);
    on<SetupPin>(_onSetupPin);
    on<ChangePin>(_onChangePin);
    on<CheckLockStatus>(_onCheckLockStatus);
    on<ResetLock>(_onResetLock);
  }

  late final SecureStorageService _secureStorage;
  late final SettingsRepository _settingsRepository;
  final LocalAuthentication _localAuth = LocalAuthentication();

  int _failedAttempts = 0;
  DateTime? _lockoutEnd;
  Timer? _lockoutTimer;

  @override
  Future<void> close() {
    _lockoutTimer?.cancel();
    return super.close();
  }

  Future<void> _onVerifyPin(VerifyPin event, Emitter<AuthState> emit) async {
    // Check if locked out
    if (_isLockedOut) {
      final remaining = _lockoutEnd!.difference(DateTime.now()).inSeconds;
      emit(AuthLockout(remaining));
      return;
    }

    final isValid = await _secureStorage.verifyPin(event.pin);

    if (isValid) {
      _failedAttempts = 0;
      _lockoutEnd = null;
      emit(const AuthUnlocked());
    } else {
      _failedAttempts++;

      if (_failedAttempts >= AppConstants.longLockoutAttempts) {
        // Long lockout
        _lockoutEnd = DateTime.now().add(
          const Duration(minutes: AppConstants.longLockoutMinutes),
        );
        _startLockoutTimer(AppConstants.longLockoutMinutes * 60);
        emit(const AuthLockout(AppConstants.longLockoutMinutes * 60));
      } else if (_failedAttempts >= AppConstants.maxPinAttempts) {
        // Short lockout
        _lockoutEnd = DateTime.now().add(
          const Duration(seconds: AppConstants.shortLockoutSeconds),
        );
        _startLockoutTimer(AppConstants.shortLockoutSeconds);
        emit(const AuthLockout(AppConstants.shortLockoutSeconds));
      } else {
        final remaining = AppConstants.maxPinAttempts - _failedAttempts;
        emit(AuthError(
          'Incorrect PIN',
          remainingAttempts: remaining,
        ));
      }
    }
  }

  Future<void> _onAuthenticateBiometric(
    AuthenticateBiometric event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (!settings.biometricEnabled) {
        emit(const AuthLocked());
        return;
      }

      final canAuthenticate = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        emit(const AuthLocked());
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Expense Calculator',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        _failedAttempts = 0;
        _lockoutEnd = null;
        emit(const AuthUnlocked());
      } else {
        emit(const AuthLocked());
      }
    } catch (e) {
      // Biometric failed — stay on PIN screen
      emit(const AuthLocked());
    }
  }

  Future<void> _onSetupPin(SetupPin event, Emitter<AuthState> emit) async {
    if (event.pin.length != AppConstants.pinLength) {
      emit(AuthError(
        'PIN must be ${AppConstants.pinLength} digits',
      ));
      return;
    }

    if (event.pin != event.confirmPin) {
      emit(const AuthError('PINs do not match'));
      return;
    }

    final hash = _secureStorage.hashPin(event.pin);
    await _secureStorage.storePin(hash);
    emit(const PinSetupSuccess());
  }

  Future<void> _onChangePin(ChangePin event, Emitter<AuthState> emit) async {
    final isValid = await _secureStorage.verifyPin(event.currentPin);
    if (!isValid) {
      emit(const AuthError('Current PIN is incorrect'));
      return;
    }

    if (event.newPin.length != AppConstants.pinLength) {
      emit(AuthError(
        'PIN must be ${AppConstants.pinLength} digits',
      ));
      return;
    }

    if (event.newPin != event.confirmNewPin) {
      emit(const AuthError('New PINs do not match'));
      return;
    }

    final hash = _secureStorage.hashPin(event.newPin);
    await _secureStorage.storePin(hash);
    emit(const PinSetupSuccess());
  }

  Future<void> _onCheckLockStatus(
    CheckLockStatus event,
    Emitter<AuthState> emit,
  ) async {
    final storedPin = await _secureStorage.getPin();
    if (storedPin == null) {
      emit(const AuthPinSetupRequired());
      return;
    }

    if (_isLockedOut) {
      final remaining = _lockoutEnd!.difference(DateTime.now()).inSeconds;
      emit(AuthLockout(remaining));
    } else {
      emit(const AuthLocked());
    }
  }

  Future<void> _onResetLock(ResetLock event, Emitter<AuthState> emit) async {
    _failedAttempts = 0;
    _lockoutEnd = null;
    _lockoutTimer?.cancel();
    emit(const AuthLocked());
  }

  bool get _isLockedOut {
    if (_lockoutEnd == null) return false;
    if (DateTime.now().isAfter(_lockoutEnd!)) {
      _lockoutEnd = null;
      return false;
    }
    return true;
  }

  void _startLockoutTimer(int seconds) {
    _lockoutTimer?.cancel();
    var remaining = seconds;
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        _lockoutEnd = null;
        add(const CheckLockStatus());
      }
    });
  }
}
