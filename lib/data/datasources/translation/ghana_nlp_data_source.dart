// ignore_for_file: avoid_print

import '../../../core/constants/app_constants.dart';
import '../../../core/data/twi_data.dart';
import '../../../core/data/ewe_data.dart';
import '../../../core/data/hausa_data.dart';
import '../../../core/data/ga_data.dart';
import 'translation_data_source.dart';

class GhanaNlpDataSource implements TranslationDataSource {
  final Map<SupportedLanguage, Map<String, String>> _dictionaries = {};

  GhanaNlpDataSource() {
    try {
      _dictionaries[SupportedLanguage.twi] = twiTranslations;
      print('Twi loaded: ${twiTranslations.length}');
    } catch (e) {
      print('Twi ERROR: $e');
      _dictionaries[SupportedLanguage.twi] = {};
    }

    try {
      _dictionaries[SupportedLanguage.ewe] = eweTranslations;
      print('Ewe loaded: ${eweTranslations.length}');
    } catch (e) {
      print('Ewe ERROR: $e');
      _dictionaries[SupportedLanguage.ewe] = {};
    }

    try {
      _dictionaries[SupportedLanguage.hausa] = hausaTranslations;
      print('Hausa loaded: ${hausaTranslations.length}');
    } catch (e) {
      print('Hausa ERROR: $e');
      _dictionaries[SupportedLanguage.hausa] = {};
    }

    try {
      _dictionaries[SupportedLanguage.ga] = gaTranslations;
      print('Ga loaded: ${gaTranslations.length}');
    } catch (e) {
      print('Ga ERROR: $e');
      _dictionaries[SupportedLanguage.ga] = {};
    }

    print('Total dictionaries: ${_dictionaries.length}');
  }

  @override
  Future<String> translate({
    required String text,
    required SupportedLanguage from,
    required SupportedLanguage to,
    required TranslationDomain domain,
  }) async {
    print('Translating: "$text"');

    if (text.trim().isEmpty) return '';

    final originalText = text.trim();
    final lowerText = originalText.toLowerCase();

    // English -> Ghanaian Language
    if (from == SupportedLanguage.english) {
      final dict = _dictionaries[to] ?? {};
      print('Dictionary size: ${dict.length}');

      // ===== METHOD 1: EXACT MATCH (CASE SENSITIVE) =====
      if (dict.containsKey(originalText)) {
        final result = dict[originalText]!;
        print('✅ EXACT MATCH: "$originalText" -> "$result"');
        return result;
      }

      // ===== METHOD 2: EXACT MATCH (CASE INSENSITIVE) =====
      for (final entry in dict.entries) {
        if (entry.key.toLowerCase() == lowerText) {
          final result = entry.value;
          print('✅ CASE-INSENSITIVE MATCH: "$originalText" -> "$result"');
          return result;
        }
      }

      // ===== METHOD 3: EXACT MATCH WITH PUNCTUATION FIXES =====
      // Try removing trailing punctuation
      final noTrailingPunct =
          originalText.replaceAll(RegExp(r'[.,!?;:"\"]$'), '');
      if (noTrailingPunct != originalText) {
        if (dict.containsKey(noTrailingPunct)) {
          final result = dict[noTrailingPunct]!;
          print(
              '✅ MATCH (no trailing punctuation): "$originalText" -> "$result"');
          return result;
        }
        // Try case insensitive
        for (final entry in dict.entries) {
          if (entry.key.toLowerCase() == noTrailingPunct.toLowerCase()) {
            final result = entry.value;
            print(
                '✅ MATCH (no trailing punct + case-insensitive): "$originalText" -> "$result"');
            return result;
          }
        }
      }

      // ===== METHOD 4: WORD-BY-WORD (ONLY FOR SHORT PHRASES < 5 WORDS) =====
      final words = originalText.split(' ');
      if (words.length <= 5 && words.length > 1) {
        final translatedWords = <String>[];
        final notFoundWords = <String>[];

        for (final word in words) {
          final lowerWord = word.toLowerCase();
          String? found;

          // Try exact match
          if (dict.containsKey(word)) {
            found = dict[word]!;
          } else {
            // Try case insensitive
            for (final entry in dict.entries) {
              if (entry.key.toLowerCase() == lowerWord) {
                found = entry.value;
                break;
              }
            }
          }

          if (found != null) {
            translatedWords.add(found);
          } else {
            notFoundWords.add(word);
            translatedWords.add(word);
          }
        }

        final result = translatedWords.join(' ');
        print('Word-by-word translation: "$originalText" -> "$result"');
        return result;
      }

      // ===== NOT FOUND =====
      print('❌ NO MATCH FOUND: "$originalText"');
      return '[${to.displayName}] Not found: "$originalText"';
    }

    // Ghanaian Language -> English
    if (to == SupportedLanguage.english) {
      final cleanLower = lowerText;
      for (final entry in _dictionaries.entries) {
        final dict = entry.value;
        for (final pair in dict.entries) {
          if (pair.value.toLowerCase().trim() == cleanLower) {
            print('Reverse found: "$originalText" -> "${pair.key}"');
            return pair.key;
          }
        }
      }
      return '[English] Not found: "$originalText"';
    }

    return 'Direct ${from.displayName} -> ${to.displayName} not supported';
  }

  void addDictionary(
      SupportedLanguage language, Map<String, String> dictionary) {
    _dictionaries[language] = dictionary;
  }
}
