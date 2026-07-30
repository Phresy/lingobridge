// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/data/twi_data.dart';
import '../../../core/data/ewe_data.dart';
import '../../../core/data/ga_data.dart';
import '../../../core/data/hausa_data.dart';
import '../../../core/data/dagbani_data.dart'; // ← ADD THIS

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build the list dynamically so counts update when data changes
    final languages = [
      _LanguageInfo(
        language: SupportedLanguage.twi,
        translations: twiTranslations,
      ),
      _LanguageInfo(
        language: SupportedLanguage.ewe,
        translations: eweTranslations,
      ),
      _LanguageInfo(
        language: SupportedLanguage.ga,
        translations: gaTranslations,
      ),
      _LanguageInfo(
        language: SupportedLanguage.hausa,
        translations: hausaTranslations,
      ),
      _LanguageInfo(
        language: SupportedLanguage.dagbani, // ← ADD THIS
        translations: dagbaniTranslations, // ← ADD THIS
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Packs'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${languages.length} installed',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final info = languages[i];
          final lang = info.language;
          final translationCount = info.translations.length;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                radius: 24,
                child: Text(
                  lang.displayName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              title: Text(
                lang.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$translationCount translations available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Installed ✓',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  _showLanguageInfo(context, lang, translationCount);
                },
                icon: const Icon(Icons.info_outline),
                tooltip: 'Info',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLanguageInfo(
    BuildContext context,
    SupportedLanguage lang,
    int count,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(lang.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.translate, color: Colors.deepPurple),
              title: const Text('Translations'),
              trailing: Text(
                count.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.deepPurple),
              title: const Text('Status'),
              trailing: const Text(
                'Installed ✓',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _LanguageInfo {
  const _LanguageInfo({
    required this.language,
    required this.translations,
  });

  final SupportedLanguage language;
  final Map<String, String> translations;
}
