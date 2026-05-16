import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPrefsProvider);
    final themeAsync = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.medium(title: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: prefsAsync.when(
              loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) =>
                  SliverFillRemaining(child: Text('Error: $e')),
              data: (prefs) => SliverList(
                delegate: SliverChildListDelegate([

                  _SectionHeader(title: 'Profile'),
                  _EditableListTile(
                    icon: Icons.person,
                    label: 'Your Name',
                    value: prefs.userName,
                    onSave: (v) =>
                        ref.read(userPrefsProvider.notifier).setUserName(v),
                  ),
                  const SizedBox(height: 16),

                  _SectionHeader(title: 'Appearance'),
                  Card(
                    child: Column(
                      children: [
                        _ThemeTile(
                          label: 'System default',
                          mode: ThemeMode.system,
                          current: themeAsync.valueOrNull ?? ThemeMode.system,
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setTheme(ThemeMode.system),
                        ),
                        _ThemeTile(
                          label: 'Light',
                          mode: ThemeMode.light,
                          current: themeAsync.valueOrNull ?? ThemeMode.system,
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setTheme(ThemeMode.light),
                        ),
                        _ThemeTile(
                          label: 'Dark',
                          mode: ThemeMode.dark,
                          current: themeAsync.valueOrNull ?? ThemeMode.system,
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setTheme(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _SectionHeader(title: 'Finance'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.currency_exchange),
                          title: const Text('Default Currency'),
                          trailing: DropdownButton<String>(
                            value: prefs.currency,
                            underline: const SizedBox.shrink(),
                            items: AppConstants.currencies
                                .map((c) => DropdownMenuItem(
                                    value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => ref
                                .read(userPrefsProvider.notifier)
                                .setCurrency(v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _SectionHeader(title: 'About'),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Finance Tracker'),
                      subtitle: const Text('v1.0.0 · Final Project'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final ThemeMode mode;
  final ThemeMode current;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: current,
      onChanged: (_) => onTap(),
    );
  }
}

class _EditableListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final void Function(String) onSave;

  const _EditableListTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
        trailing: const Icon(Icons.edit),
        onTap: () async {
          final ctrl = TextEditingController(text: value);
          final result = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Edit $label'),
              content: TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(labelText: label),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(ctrl.text),
                    child: const Text('Save')),
              ],
            ),
          );
          if (result != null && result.trim().isNotEmpty) {
            onSave(result.trim());
          }
        },
      ),
    );
  }
}

