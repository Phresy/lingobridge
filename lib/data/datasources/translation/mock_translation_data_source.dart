import '../../../core/constants/app_constants.dart';
import 'translation_data_source.dart';

/// Deliberately NOT a real translator. It exists so the full UI → use-case
/// → history-persistence pipeline can be built and tested now, in Phase 2,
/// without waiting on Khaya API credentials or a fine-tuned NLLB model.
/// Swapping this out in Phase 3 is a one-line change in
/// `translation_provider.dart` — nothing else in the app knows this class
/// exists.
class MockTranslationDataSource implements TranslationDataSource {
  @override
  Future<String> translate({
    required String text,
    required SupportedLanguage from,
    required SupportedLanguage to,
    required TranslationDomain domain,
  }) async {
    // Simulated latency so loading states are visible/testable in the UI.
    await Future.delayed(const Duration(milliseconds: 650));

    if (text.trim().isEmpty) return '';

    return '[${to.displayName} · ${domain.label}] $text';
  }
}
