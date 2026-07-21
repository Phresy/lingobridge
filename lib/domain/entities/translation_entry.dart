import '../../core/constants/app_constants.dart';

/// Pure domain model. Deliberately has no `fromMap`/`toJson` — those belong
/// to `data/models/translation_model.dart`. Keeping this class ignorant of
/// SQLite means the UI and use-cases never depend on a database detail.
class TranslationEntry {
  const TranslationEntry({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.domain,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String sourceText;
  final String translatedText;
  final SupportedLanguage sourceLanguage;
  final SupportedLanguage targetLanguage;
  final TranslationDomain domain;
  final DateTime createdAt;
  final bool isFavorite;

  TranslationEntry copyWith({bool? isFavorite}) => TranslationEntry(
        id: id,
        sourceText: sourceText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        domain: domain,
        createdAt: createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
