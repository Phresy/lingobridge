import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class AutoDetectState {
  const AutoDetectState({
    this.enabled = false,
    this.detectedLanguage = 'en',
  });

  final bool enabled;
  final String detectedLanguage;

  AutoDetectState copyWith({
    bool? enabled,
    String? detectedLanguage,
  }) {
    return AutoDetectState(
      enabled: enabled ?? this.enabled,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }
}

class AutoDetectNotifier extends StateNotifier<AutoDetectState> {
  AutoDetectNotifier() : super(const AutoDetectState()) {
    _load();
  }

  // Common words for each language (simple detection)
  static const Map<String, List<String>> _languageKeywords = {
    'en': [
      'the',
      'and',
      'you',
      'that',
      'for',
      'are',
      'but',
      'not',
      'have',
      'this',
      'with',
      'from'
    ],
    'tw': [
      'wo',
      'me',
      'ne',
      'na',
      'de',
      'ma',
      'ka',
      'se',
      'ni',
      'di',
      'ko',
      'pa'
    ],
    'ee': [
      'wo',
      'me',
      'ne',
      'na',
      'de',
      'ma',
      'ka',
      'se',
      'ni',
      'di',
      'ko',
      'pa'
    ],
    'gaa': [
      'mi',
      'bo',
      'te',
      'nu',
      'ke',
      'le',
      'mo',
      'to',
      'ko',
      'ne',
      'ye',
      'fo'
    ],
    'ha': [
      'na',
      'da',
      'ni',
      'su',
      'ga',
      'mu',
      'ba',
      'ka',
      'ta',
      'ma',
      'ya',
      'ke'
    ],
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(StorageKeys.autoDetectLanguage) ?? false;
    state = state.copyWith(enabled: enabled);
  }

  Future<void> toggle() async {
    final newValue = !state.enabled;
    state = state.copyWith(enabled: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.autoDetectLanguage, newValue);
  }

  Future<String> detectLanguage(String text) async {
    // If auto-detect is disabled or text is too short, return English
    if (!state.enabled || text.trim().isEmpty) {
      return 'en';
    }

    // Only detect if text has enough words
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    if (words.length < 3) {
      return 'en';
    }

    // Count matches for each language
    final scores = <String, int>{};
    for (final entry in _languageKeywords.entries) {
      final lang = entry.key;
      final keywords = entry.value;
      int score = 0;

      for (final word in words) {
        // Remove punctuation
        final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');
        if (cleanWord.isNotEmpty && keywords.contains(cleanWord)) {
          score++;
        }
      }

      if (score > 0) {
        scores[lang] = score;
      }
    }

    // If no matches, return English
    if (scores.isEmpty) {
      return 'en';
    }

    // Find the language with the highest score
    String detected = 'en';
    int maxScore = 0;

    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        detected = entry.key;
      }
    }

    state = state.copyWith(detectedLanguage: detected);
    return detected;
  }
}

final autoDetectLanguageProvider =
    StateNotifierProvider<AutoDetectNotifier, AutoDetectState>(
  (ref) => AutoDetectNotifier(),
);
