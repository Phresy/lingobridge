import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/translation/ghana_nlp_data_source.dart'; // ← Updated path
import '../../data/datasources/translation/translation_data_source.dart';
import '../../data/repositories/translation_repository_impl.dart';
import '../../domain/repositories/translation_repository.dart';
import '../../domain/usecases/translate_and_save_usecase.dart';

final translationRepositoryProvider = Provider<TranslationRepository>(
  (ref) => SqliteTranslationRepository(),
);

final translationDataSourceProvider = Provider<TranslationDataSource>(
  (ref) => GhanaNlpDataSource(),
);

final translateAndSaveUseCaseProvider = Provider<TranslateAndSaveUseCase>(
  (ref) => TranslateAndSaveUseCase(
    dataSource: ref.watch(translationDataSourceProvider),
    repository: ref.watch(translationRepositoryProvider),
  ),
);

final hasKhayaApiKeyProvider = FutureProvider.autoDispose<bool>((ref) async {
  return false;
});
