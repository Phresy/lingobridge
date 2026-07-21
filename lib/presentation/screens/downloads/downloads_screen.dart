import 'package:flutter/material.dart';

// FIXED: Correct import path (3 levels up is correct for this file)
import '../../../../../../core/constants/app_constants.dart';

/// Phase 1 scaffold listing downloadable language packs. Actual download
/// progress/storage wiring (SQLite + Firebase/Supabase Storage) is Phase 4.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  static const _downloadable = [
    SupportedLanguage.twi,
    SupportedLanguage.ewe,
    SupportedLanguage.ga,
    SupportedLanguage.hausa,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Packs'),
        backgroundColor: scheme.surface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _downloadable.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final lang = _downloadable[i];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.translate_rounded,
                  color: scheme.primary,
                ),
              ),
              title: Text(
                lang.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                lang.packSizeLabel,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              trailing: FilledButton.tonal(
                onPressed: () {
                  // Phase 4: Download language pack
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Downloading ${lang.displayName}...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Download'),
              ),
            ),
          );
        },
      ),
    );
  }
}