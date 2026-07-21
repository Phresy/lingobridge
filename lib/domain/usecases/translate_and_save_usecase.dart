import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/translation/translation_data_source.dart';
import '../entities/translation_entry.dart';
import '../repositories/translation_repository.dart';

/// Coordinates two things that always happen together: producing a
/// translation and saving it to history. Putting this in `domain/usecases`
/// (rather than inline in the screen's StateNotifier) means the same flow
/// can be reused later — e.g. a future "translate from share sheet" entry
/// point calls this exact class instead of duplicating the save-to-history
/// logic.
class TranslateAndSaveUseCase {
  TranslateAndSaveUseCase({
    required TranslationDataSource dataSource,
    required TranslationRepository repository,
  })  : _dataSource = dataSource,
        _repository = repository;

  final TranslationDataSource _dataSource;
  final TranslationRepository _repository;
  final _uuid = const Uuid();

  Future<TranslationEntry> call({
    required String sourceText,
    required SupportedLanguage from,
    required SupportedLanguage to,
    required TranslationDomain domain,
  }) async {
    final translated = await _dataSource.translate(
      text: sourceText,
      from: from,
      to: to,
      domain: domain,
    );

    final entry = TranslationEntry(
      id: _uuid.v4(),
      sourceText: sourceText,
      translatedText: translated,
      sourceLanguage: from,
      targetLanguage: to,
      domain: domain,
      createdAt: DateTime.now(),
    );

    return _repository.addEntry(entry);
  }
}
