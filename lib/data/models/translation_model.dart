import '../../core/constants/app_constants.dart';
import '../../domain/entities/translation_entry.dart';

/// Translates between SQLite's flat row shape and the domain entity.
/// Enums are stored as their `.code`/`.name` string rather than an int
/// index — an int index breaks silently if enum order ever changes;
/// a string survives reordering.
class TranslationModel {
  const TranslationModel({required this.entry});

  final TranslationEntry entry;

  Map<String, Object?> toMap() => {
        'id': entry.id,
        'source_text': entry.sourceText,
        'translated_text': entry.translatedText,
        'source_language': entry.sourceLanguage.code,
        'target_language': entry.targetLanguage.code,
        'domain': entry.domain.name,
        'created_at': entry.createdAt.millisecondsSinceEpoch,
        'is_favorite': entry.isFavorite ? 1 : 0,
      };

  static TranslationEntry fromMap(Map<String, Object?> map) {
    return TranslationEntry(
      id: map['id'] as String,
      sourceText: map['source_text'] as String,
      translatedText: map['translated_text'] as String,
      sourceLanguage: SupportedLanguage.values
          .firstWhere((l) => l.code == map['source_language']),
      targetLanguage: SupportedLanguage.values
          .firstWhere((l) => l.code == map['target_language']),
      domain: TranslationDomain.values
          .firstWhere((d) => d.name == map['domain']),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }
}
