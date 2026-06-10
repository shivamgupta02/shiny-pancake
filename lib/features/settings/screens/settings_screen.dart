import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../../categories/screens/category_list_screen.dart';
import '../../sms/screens/sms_scan_screen.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/change_pin_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc()..add(const LoadSettings()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is BackupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Backup created successfully'),
                action: SnackBarAction(
                  label: 'Share',
                  onPressed: () {
                    Share.shareXFiles([XFile(state.filePath)]);
                  },
                ),
              ),
            );
          } else if (state is RestoreSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data restored successfully'),
              ),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        buildWhen: (_, current) => current is SettingsLoaded,
        builder: (context, state) {
          if (state is SettingsLoaded) {
            return _buildSettingsList(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, SettingsLoaded state) {
    final settings = state.settings;

    return ListView(
      children: [
        // Appearance section
        _buildSectionHeader(context, 'Appearance'),
        _buildThemeTile(context, settings.themeMode),
        const Divider(height: 1),

        // Security section
        _buildSectionHeader(context, 'Security'),
        _buildTimeoutTile(context, settings.timeoutMinutes),
        const Divider(height: 1),
        _buildBiometricTile(context, settings.biometricEnabled),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.pin_outlined),
          title: const Text('Change PIN'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showChangePinDialog(context),
        ),
        const Divider(height: 1),

        // Data section
        _buildSectionHeader(context, 'Data'),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Manage Categories'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CategoryListScreen(),
              ),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.sms_outlined),
          title: const Text('SMS Expense Detection'),
          subtitle: const Text('Scan messages for transactions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SmsScanScreen(),
              ),
            );
          },
        ),
        const Divider(height: 1),

        // Backup & Restore section
        _buildSectionHeader(context, 'Backup & Restore'),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Backup Data'),
          subtitle: state.lastBackupInfo != null
              ? Text('Last backup: ${state.lastBackupInfo}')
              : const Text('No backups yet'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _confirmBackup(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.restore_outlined),
          title: const Text('Restore Data'),
          subtitle: const Text('Import from backup file'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _confirmRestore(context),
        ),
        const Divider(height: 1),

        // About section
        _buildSectionHeader(context, 'About'),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text(AppConstants.appName),
          subtitle: Text('Version ${AppConstants.appVersion}'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, int currentMode) {
    const themes = ['System', 'Light', 'Dark'];

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme'),
      subtitle: Text(themes[currentMode]),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Choose Theme'),
            children: List.generate(3, (index) {
              return SimpleDialogOption(
                onPressed: () {
                  context.read<SettingsBloc>().add(ChangeTheme(index));
                  Navigator.of(dialogContext).pop();
                  // Update app-level theme immediately
                  final appState = ExpenseCalculatorApp.of(context);
                  appState?.updateTheme(index);
                },
                child: Row(
                  children: [
                    Icon(
                      index == currentMode
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(themes[index]),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildTimeoutTile(BuildContext context, int currentMinutes) {
    String formatTimeout(int minutes) {
      if (minutes == 0) return 'Immediately';
      if (minutes == 1) return '1 minute';
      return '$minutes minutes';
    }

    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: const Text('Auto-Lock Timeout'),
      subtitle: Text(formatTimeout(currentMinutes)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Auto-Lock Timeout'),
            children: AppConstants.timeoutOptions.map((minutes) {
              return SimpleDialogOption(
                onPressed: () {
                  context.read<SettingsBloc>().add(ChangeTimeout(minutes));
                  Navigator.of(dialogContext).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      minutes == currentMinutes
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(formatTimeout(minutes)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBiometricTile(BuildContext context, bool enabled) {
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Biometric Unlock'),
      subtitle: const Text('Use fingerprint or face to unlock'),
      value: enabled,
      onChanged: (value) {
        context.read<SettingsBloc>().add(ToggleBiometric(value));
      },
    );
  }

  void _showChangePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChangePinDialog(),
    );
  }

  void _confirmBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Backup'),
        content: const Text(
          'This will export all your data (expenses, categories, and settings) to a JSON file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SettingsBloc>().add(const CreateBackup());
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace ALL existing data with the backup data. This action cannot be undone.\n\nSelect a backup file to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // In a real app, this would use file_picker to select a file
              // For now, show a message that file picker integration is needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'File picker integration required for restore',
                  ),
                ),
              );
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }
}
