// ignore_for_file: avoid_print

import '../../../core/constants/app_constants.dart';
import '../../../core/data/twi_data.dart';
import '../../../core/data/ewe_data.dart';
import '../../../core/data/hausa_data.dart';
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

    _dictionaries[SupportedLanguage.ga] = {};
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

    final cleanText = text.trim().toLowerCase();

    // English -> Ghanaian Language
    if (from == SupportedLanguage.english) {
      final dict = _dictionaries[to] ?? {};
      print('Dictionary size: ${dict.length}');

      // METHOD 1: EXACT MATCH
      if (dict.containsKey(cleanText)) {
        final result = dict[cleanText]!;
        print('Exact match: "$text" -> "$result"');
        return result;
      }

      // METHOD 2: REMOVE TRAILING PUNCTUATION
      final noPunctuation = cleanText.replaceAll(RegExp(r'[.,!?;:"\"]$'), '');
      if (noPunctuation != cleanText && dict.containsKey(noPunctuation)) {
        final result = dict[noPunctuation]!;
        print('No punctuation: "$text" -> "$result"');
        return result;
      }

      // METHOD 3: SINGLE WORD - APPLY STEMMING (ONLY IF NOT FOUND ABOVE)
      final stemmed = _stemWord(cleanText);
      if (stemmed != cleanText && dict.containsKey(stemmed)) {
        final result = dict[stemmed]!;
        print('Stemming applied: "$text" -> "$result"');
        return result;
      }

      // METHOD 4: WORD-BY-WORD TRANSLATION
      final words = cleanText.split(' ');
      if (words.length > 1) {
        final translatedWords = <String>[];
        final notFoundWords = <String>[];

        for (final word in words) {
          // First try exact match
          if (dict.containsKey(word)) {
            translatedWords.add(dict[word]!);
          } else {
            // Only apply stemming if exact match fails
            final stemmedWord = _stemWord(word);
            if (stemmedWord != word && dict.containsKey(stemmedWord)) {
              translatedWords.add(dict[stemmedWord]!);
              print('Stemming applied to "$word" -> "$stemmedWord"');
            } else {
              notFoundWords.add(word);
              translatedWords.add(word); // Keep original if not found
            }
          }
        }

        final result = translatedWords.join(' ');
        if (notFoundWords.isEmpty) {
          print('Word-by-word complete: "$text" -> "$result"');
        } else {
          print(
              'Word-by-word (${notFoundWords.length} words not found): "$text" -> "$result"');
        }
        return result;
      }

      // METHOD 5: PARTIAL MATCH (last resort - ONLY for single words not found above)
      for (final entry in dict.entries) {
        final key = entry.key.toLowerCase();
        if (key.contains(cleanText) || cleanText.contains(key)) {
          final result = entry.value;
          print(
              'Partial match: "$text" -> "$result" (matched: "${entry.key}")');
          return result;
        }
      }

      // NOT FOUND
      print('Not found: "$text"');
      return '[${to.displayName}] Not found: "$text"';
    }

    // Ghanaian Language -> English
    if (to == SupportedLanguage.english) {
      final cleanLower = cleanText.toLowerCase();
      for (final entry in _dictionaries.entries) {
        final dict = entry.value;
        for (final pair in dict.entries) {
          if (pair.value.toLowerCase().trim() == cleanLower) {
            print('Reverse found: "$text" -> "${pair.key}"');
            return pair.key;
          }
        }
      }
      return '[English] Not found: "$text"';
    }

    return 'Direct ${from.displayName} -> ${to.displayName} not supported';
  }

  // ===== STEM FUNCTION (only applied when word is NOT found in dictionary) =====
  String _stemWord(String word) {
    // Remove common suffixes
    if (word.endsWith('ing') && word.length > 4) {
      return word.substring(0, word.length - 3);
    }
    if (word.endsWith('ed') && word.length > 3) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('s') && word.length > 2 && !word.endsWith('ss')) {
      return word.substring(0, word.length - 1);
    }
    if (word.endsWith('es') && word.length > 3) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('ly') && word.length > 3) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('ment') && word.length > 5) {
      return word.substring(0, word.length - 4);
    }
    if (word.endsWith('tion') && word.length > 5) {
      return word.substring(0, word.length - 3);
    }
    if (word.endsWith('ness') && word.length > 5) {
      return word.substring(0, word.length - 4);
    }
    return word; // No change if no suffix matches
  }

  void addDictionary(
      SupportedLanguage language, Map<String, String> dictionary) {
    _dictionaries[language] = dictionary;
  }
}
