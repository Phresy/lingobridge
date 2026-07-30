// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../providers/font_scale_provider.dart';
import '../../providers/speech_settings_provider.dart';
import '../../providers/auto_detect_provider.dart';
import '../../providers/connectivity_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final speechSettings = ref.watch(speechSettingsProvider);
    final autoDetectState = ref.watch(autoDetectLanguageProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final isOnline = connectivityState.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ===== APPEARANCE SECTION =====
          _buildSectionHeader(context, 'Appearance'),

          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),

          ListTile(
            leading: const Icon(Icons.text_fields_rounded),
            title: const Text('Font Size'),
            subtitle: Text('${(fontScale * 100).round()}%'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showFontSizeSheet(context, ref),
          ),

          // ===== SPEECH SECTION =====
          _buildSectionHeader(context, 'Speech'),

          ListTile(
            leading: const Icon(Icons.speed_rounded),
            title: const Text('Speech Speed'),
            subtitle: Text('${(speechSettings.speed * 100).round()}%'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showSpeechSpeedSheet(context, ref),
          ),

          ListTile(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: const Text('Speech Gender'),
            subtitle: Text(
              speechSettings.gender == SpeechGender.female ? 'Female' : 'Male',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showSpeechGenderSheet(context, ref),
          ),

          // ===== LANGUAGE SECTION =====
          _buildSectionHeader(context, 'Language'),

          SwitchListTile(
            title: const Text('Auto Detect Language'),
            secondary: const Icon(Icons.auto_awesome_rounded),
            value: autoDetectState.enabled,
            onChanged: (_) =>
                ref.read(autoDetectLanguageProvider.notifier).toggle(),
          ),

          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Color'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme color picker coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // ===== TRANSLATION SECTION =====
          _buildSectionHeader(context, 'Translation'),

          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: const Text('Translation Engine'),
            subtitle: const Text('Using GhanaNLP offline data'),
            trailing:
                const Icon(Icons.check_circle_rounded, color: Colors.green),
            onTap: () {},
          ),

          // ===== INFO SECTION =====
          _buildSectionHeader(context, 'Info'),

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

          ListTile(
            leading: const Icon(Icons.wifi_rounded),
            title: const Text('Status'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(isOnline ? 'Online' : 'Offline'),
              ],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  // ===== FONT SIZE SHEET =====
  void _showFontSizeSheet(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(fontScaleProvider);
    final notifier = ref.read(fontScaleProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Font Size',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: scale,
                      min: FontScaleNotifier.min,
                      max: FontScaleNotifier.max,
                      divisions: 9,
                      label: '${(scale * 100).round()}%',
                      onChanged: (value) => notifier.setScale(value),
                    ),
                  ),
                  Text('A', style: TextStyle(fontSize: 28)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Preview: The quick brown fox jumps over the lazy dog.',
                style: TextStyle(fontSize: 16 * scale),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== SPEECH SPEED SHEET =====
  void _showSpeechSpeedSheet(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(speechSettingsProvider);
    final notifier = ref.read(speechSettingsProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Speech Speed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Current speed: ${(settings.speed * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: settings.speed,
                min: 0.25,
                max: 1.0,
                divisions: 6,
                label: '${(settings.speed * 100).round()}%',
                onChanged: (value) => notifier.setSpeed(value),
              ),
              const SizedBox(height: 16),
              Text(
                'Try it: Tap the play button on any translation.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== SPEECH GENDER SHEET =====
  void _showSpeechGenderSheet(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(speechSettingsProvider);
    final notifier = ref.read(speechSettingsProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Speech Gender',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select the voice gender for text-to-speech.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 16),
              RadioListTile<SpeechGender>(
                title: const Text('Female Voice'),
                value: SpeechGender.female,
                groupValue: settings.gender,
                onChanged: (value) {
                  if (value != null) {
                    notifier.setGender(value);
                    Navigator.pop(context);
                  }
                },
                secondary: const Icon(Icons.female),
              ),
              RadioListTile<SpeechGender>(
                title: const Text('Male Voice'),
                value: SpeechGender.male,
                groupValue: settings.gender,
                onChanged: (value) {
                  if (value != null) {
                    notifier.setGender(value);
                    Navigator.pop(context);
                  }
                },
                secondary: const Icon(Icons.male),
              ),
              const SizedBox(height: 8),
              Text(
                'Note: Voice availability depends on your device\'s TTS engine.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
