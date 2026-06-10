import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingStep) {
          setState(() {
            _errorMessage = null;
          });
          _animateToPage(state.currentStep);
          if (state.currentStep == 4) {
            // Auto-complete when reaching step 4
            context.read<OnboardingBloc>().add(const CompleteOnboarding());
          }
        } else if (state is OnboardingError) {
          setState(() {
            _errorMessage = state.message;
          });
        } else if (state is OnboardingComplete) {
          widget.onComplete();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildWelcomePage(),
              _buildNamePage(),
              _buildPinPage(),
              _buildSmsPage(),
              const SizedBox.shrink(), // Placeholder for completion transition
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Track your expenses effortlessly',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => _animateToPage(1),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What\'s your name?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use this to personalize your experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitName(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submitName,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _submitName() {
    context.read<OnboardingBloc>().add(SetName(_nameController.text));
  }

  Widget _buildPinPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Set up your PIN',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a ${AppConstants.pinLength}-digit PIN to secure your data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _pinController,
            decoration: const InputDecoration(
              labelText: 'Enter PIN',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: AppConstants.pinLength,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPinController,
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
              prefixIcon: Icon(Icons.lock_outline),
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
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submitPin,
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  void _submitPin() {
    context.read<OnboardingBloc>().add(
          SetupPin(
            pin: _pinController.text,
            confirmPin: _confirmPinController.text,
          ),
        );
  }

  Widget _buildSmsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sms_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'SMS Auto-Detection',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Allow the app to read transaction SMS messages to automatically detect expenses.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () {
              context
                  .read<OnboardingBloc>()
                  .add(const RequestSmsPermission());
            },
            child: const Text('Allow'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context
                  .read<OnboardingBloc>()
                  .add(const SkipSmsPermission());
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
