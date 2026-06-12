import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_shell.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/screens/pin_screen.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/sms/screens/sms_scan_screen.dart';
import 'services/sms_parsing_service.dart';
import 'services/sms_reader_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupServiceLocator();
  await getIt<CategoryRepository>().seedDefaults();

  runApp(const ExpenseCalculatorApp());
}

class ExpenseCalculatorApp extends StatefulWidget {
  const ExpenseCalculatorApp({super.key});

  static _ExpenseCalculatorAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ExpenseCalculatorAppState>();

  @override
  State<ExpenseCalculatorApp> createState() => _ExpenseCalculatorAppState();
}

class _ExpenseCalculatorAppState extends State<ExpenseCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final settings = await getIt<SettingsRepository>().getSettings();
    setState(() {
      _themeMode = _intToThemeMode(settings.themeMode);
    });
  }

  void updateTheme(int mode) {
    setState(() {
      _themeMode = _intToThemeMode(mode);
    });
  }

  ThemeMode _intToThemeMode(int mode) {
    switch (mode) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getIt<SettingsRepository>().isOnboardingComplete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isOnboardingComplete = snapshot.data ?? false;

        if (!isOnboardingComplete) {
          return BlocProvider(
            create: (_) => OnboardingBloc(),
            child: OnboardingScreen(
              onComplete: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const _AuthGate()),
                );
              },
            ),
          );
        }

        return const _AuthGate();
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> with WidgetsBindingObserver {
  bool _isUnlocked = false;
  DateTime? _lastInteraction;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authBloc = AuthBloc()..add(const CheckLockStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastInteraction = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _isUnlocked) {
      _checkTimeout();
      _checkPendingSms();
    }
  }

  Future<void> _checkPendingSms() async {
    final smsReader = getIt<SmsReaderService>();
    final smsParser = getIt<SmsParsingService>();

    final pending = await smsReader.getPendingMessages();
    if (pending.isEmpty) return;

    int detected = 0;
    for (final msg in pending) {
      final body = msg['body'] as String? ?? '';
      final result = smsParser.parseMessage(body);
      if (result != null && result.confidence >= 0.4) {
        detected++;
      }
    }

    // Don't clear here — the ScanPendingMessages event will clear them
    if (detected > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$detected new expense(s) detected from SMS'),
          action: SnackBarAction(
            label: 'Review',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SmsScanScreen(scanPending: true),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _checkTimeout() async {
    if (_lastInteraction == null) return;

    final settings = await getIt<SettingsRepository>().getSettings();
    final timeoutMinutes = settings.timeoutMinutes;

    if (timeoutMinutes == 0) {
      setState(() => _isUnlocked = false);
      _authBloc.add(const CheckLockStatus());
      return;
    }

    final elapsed = DateTime.now().difference(_lastInteraction!);
    if (elapsed.inMinutes >= timeoutMinutes) {
      setState(() => _isUnlocked = false);
      _authBloc.add(const CheckLockStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return const AppShell();
    }

    return BlocProvider.value(
      value: _authBloc,
      child: PinScreen(
        onUnlocked: () {
          setState(() {
            _isUnlocked = true;
            _lastInteraction = DateTime.now();
          });
        },
      ),
    );
  }
}
