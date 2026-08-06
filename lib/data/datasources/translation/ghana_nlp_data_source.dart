// ignore_for_file: avoid_print

import '../../../core/constants/app_constants.dart';
import '../../../core/data/twi_data.dart';
import '../../../core/data/ewe_data.dart';
import '../../../core/data/hausa_data.dart';
import '../../../core/data/ga_data.dart';
import '../../../core/data/dagbani_data.dart';
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

    try {
      _dictionaries[SupportedLanguage.dagbani] = dagbaniTranslations;
      print('Dagbani loaded: ${dagbaniTranslations.length}');
    } catch (e) {
      print('Dagbani ERROR: $e');
      _dictionaries[SupportedLanguage.dagbani] = {};
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
    final cleanedInput = _removePunctuation(originalText);
    final lowerCleanedInput = cleanedInput.toLowerCase();

    // English -> Ghanaian Language
    if (from == SupportedLanguage.english) {
      final dict = _dictionaries[to] ?? {};
      print('Dictionary size: ${dict.length}');

      // ===== METHOD 1: EXACT MATCH (PRESERVES PUNCTUATION) =====
      if (dict.containsKey(originalText)) {
        final result = dict[originalText]!;
        print('✅ EXACT MATCH: "$originalText" -> "$result"');
        return result;
      }

      // ===== METHOD 2: CLEANED TEXT MATCH (Compare cleaned versions) =====
      // Loop through dictionary and compare cleaned keys
      String? bestMatch;
      String? bestTranslation;

      for (final entry in dict.entries) {
        final cleanedKey = _removePunctuation(entry.key).toLowerCase();
        if (cleanedKey == lowerCleanedInput) {
          bestMatch = entry.key;
          bestTranslation = entry.value;
          break;
        }
      }

      if (bestMatch != null && bestTranslation != null) {
        print('✅ CLEANED MATCH: "$bestMatch" -> "$bestTranslation"');
        return bestTranslation;
      }

      // ===== METHOD 3: PHRASE MATCHING (LONGEST PHRASES FIRST) =====
      final words = cleanedInput.split(' ');
      if (words.length > 1) {
        final translatedWords = <String>[];
        int i = 0;

        while (i < words.length) {
          String? foundTranslation;
          int foundLength = 0;

          // Start from longest possible phrase (5 words max, or remaining words)
          final maxPhraseLength = (words.length - i).clamp(1, 5);

          for (int length = maxPhraseLength; length >= 1; length--) {
            final phrase = words.sublist(i, i + length).join(' ');

            // Check if this phrase exists in the dictionary
            String? match;
            if (dict.containsKey(phrase)) {
              match = dict[phrase];
            } else {
              // Try case insensitive
              for (final entry in dict.entries) {
                if (entry.key.toLowerCase() == phrase.toLowerCase()) {
                  match = entry.value;
                  break;
                }
              }
            }

            if (match != null) {
              foundTranslation = match;
              foundLength = length;
              break;
            }
          }

          if (foundTranslation != null && foundLength > 0) {
            translatedWords.add(foundTranslation);
            i += foundLength;
          } else {
            // Word not found - keep original
            translatedWords.add(words[i]);
            i++;
          }
        }

        final result = translatedWords.join(' ');
        print('✅ PHRASE TRANSLATION: "$cleanedInput" -> "$result"');
        return result;
      }

      // ===== METHOD 4: SINGLE WORD =====
      // Try exact match for single word
      if (dict.containsKey(cleanedInput)) {
        return dict[cleanedInput]!;
      }

      // Try case insensitive for single word
      for (final entry in dict.entries) {
        if (entry.key.toLowerCase() == lowerCleanedInput) {
          return entry.value;
        }
      }

      // ===== NOT FOUND =====
      print('❌ NO MATCH FOUND: "$cleanedInput"');
      return '[${to.displayName}] Not found: "$originalText"';
    }

    // Ghanaian Language -> English
    if (to == SupportedLanguage.english) {
      final cleanLower = cleanedInput.toLowerCase();

      for (final entry in _dictionaries.entries) {
        final dict = entry.value;
        for (final pair in dict.entries) {
          final cleanedValue =
              _removePunctuation(pair.value).toLowerCase().trim();
          if (cleanedValue == cleanLower) {
            print('Reverse found: "$cleanedInput" -> "${pair.key}"');
            return pair.key;
          }
        }
      }
      return '[English] Not found: "$originalText"';
    }

    return 'Direct ${from.displayName} -> ${to.displayName} not supported';
  }

  // ===== PUNCTUATION REMOVAL FUNCTION =====
  String _removePunctuation(String text) {
    // Remove punctuation: .,!?;:()[]{}"'@#$%^&*+=/|~` etc.
    String cleaned = text.replaceAll(
      RegExp(r'''[.,!?;:()\[\]{}"'@#\$%^&*+=/|~`]'''),
      ' ',
    );

    // Remove extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  void addDictionary(
      SupportedLanguage language, Map<String, String> dictionary) {
    _dictionaries[language] = dictionary;
  }
}
