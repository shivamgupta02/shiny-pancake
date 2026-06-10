import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/settings_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key, this.onUnlocked});

  final VoidCallback? onUnlocked;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String? _errorMessage;
  int? _remainingAttempts;
  int _lockoutSeconds = 0;
  Timer? _countdownTimer;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final settings = await getIt<SettingsRepository>().getSettings();
    if (mounted) {
      setState(() {
        _biometricEnabled = settings.biometricEnabled;
      });
      if (_biometricEnabled) {
        context.read<AuthBloc>().add(const AuthenticateBiometric());
      }
    }
  }

  void _onDigitPressed(int digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() {
      _pin += digit.toString();
      _errorMessage = null;
    });

    if (_pin.length == AppConstants.pinLength) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  void _submitPin() {
    if (_pin.length < AppConstants.pinLength) return;
    context.read<AuthBloc>().add(VerifyPin(_pin));
    setState(() {
      _pin = '';
    });
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _lockoutSeconds = seconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _lockoutSeconds--;
          if (_lockoutSeconds <= 0) {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnlocked) {
          widget.onUnlocked?.call();
        } else if (state is AuthError) {
          setState(() {
            _errorMessage = state.message;
            _remainingAttempts = state.remainingAttempts;
          });
        } else if (state is AuthLockout) {
          _startCountdown(state.remainingSeconds);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter PIN',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              // PIN dots
              _buildPinDots(),
              const SizedBox(height: 16),
              // Error or lockout message
              _buildStatusMessage(),
              const Spacer(),
              // Numeric keypad
              _buildKeypad(),
              const SizedBox(height: 16),
              // Biometric and submit buttons
              _buildBottomActions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppConstants.pinLength, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusMessage() {
    if (_lockoutSeconds > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'Too many attempts. Try again in ${_lockoutSeconds}s',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          _remainingAttempts != null
              ? '$_errorMessage ($_remainingAttempts attempts remaining)'
              : _errorMessage!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const SizedBox(height: 20);
  }

  Widget _buildKeypad() {
    final isLocked = _lockoutSeconds > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (int row = 0; row < 3; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildKeypadButton(
                    label: '${row * 3 + col + 1}',
                    onTap: isLocked
                        ? null
                        : () => _onDigitPressed(row * 3 + col + 1),
                  ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _buildKeypadButton(
                label: '0',
                onTap: isLocked ? null : () => _onDigitPressed(0),
              ),
              _buildKeypadButton(
                icon: Icons.backspace_outlined,
                onTap: isLocked ? null : _onBackspace,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton({
    String? label,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 28)
            : Text(
                label ?? '',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_biometricEnabled)
          TextButton.icon(
            onPressed: _lockoutSeconds > 0
                ? null
                : () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthenticateBiometric());
                  },
            icon: const Icon(Icons.fingerprint),
            label: const Text('Use Biometric'),
          ),
      ],
    );
  }
}
