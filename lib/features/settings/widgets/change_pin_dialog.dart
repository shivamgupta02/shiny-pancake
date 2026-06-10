import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart' as auth_event;
import '../../auth/bloc/auth_state.dart';

class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PinSetupSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN changed successfully')),
            );
          } else if (state is AuthError) {
            setState(() {
              _errorMessage = state.message;
            });
          }
        },
        child: AlertDialog(
          title: const Text('Change PIN'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPinController,
                  decoration: const InputDecoration(
                    labelText: 'Current PIN',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: AppConstants.pinLength,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPinController,
                  decoration: const InputDecoration(
                    labelText: 'New PIN',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: AppConstants.pinLength,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPinController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New PIN',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: AppConstants.pinLength,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          auth_event.ChangePin(
                            currentPin: _currentPinController.text,
                            newPin: _newPinController.text,
                            confirmNewPin: _confirmPinController.text,
                          ),
                        );
                  },
                  child: const Text('Change'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
