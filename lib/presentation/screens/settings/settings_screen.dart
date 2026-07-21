import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (authState.status == AuthStatus.authenticated)
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_rounded),
              ),
              title: Text(
                authState.userId ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('View profile'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile screen coming in Phase 2'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          const Divider(height: 24),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields_rounded),
            title: const Text('Font Size'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Font size settings coming in Phase 2'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed_rounded),
            title: const Text('Speech Speed'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Speech settings coming in Phase 3'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: const Text('Speech Gender'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Speech gender settings coming in Phase 3'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Auto Detect Language'),
            secondary: const Icon(Icons.auto_awesome_rounded),
            value: false,
            onChanged: (bool value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Auto-detect coming in Phase 3'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Color'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme color picker coming in Phase 2'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 24),
          // NEW: Translation Engine Setting
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: const Text('Translation Engine'),
            subtitle: const Text('Using GhanaNLP offline data'),
            trailing:
                const Icon(Icons.check_circle_rounded, color: Colors.green),
            onTap: () {},
          ),
          const Divider(height: 24),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              await authNotifier.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Version'),
            trailing: const Text(
              '0.1.0',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
