import '../../../core/constants/app_constants.dart';
import 'khaya_translation_data_source.dart';
import 'mock_translation_data_source.dart';
import 'translation_data_source.dart';

/// Decides, per call, whether to use the real Khaya API or the offline
/// mock. This is the single seam the rest of the app depends on
/// (`translationDataSourceProvider`) — screens never know which one ran.
///
/// Behaviour:
/// - No Khaya key configured → mock, silently (expected default state
///   for a fresh install).
/// - Key configured but the call fails (bad key, Khaya API down, no
///   internet) → the error is real and surfaced to the user, rather than
///   silently falling back to mock text that looks like a real
///   translation. Silently mixing real and fake translations would be
///   worse than a visible error.
class SmartTranslationDataSource implements TranslationDataSource {
  SmartTranslationDataSource({
    KhayaTranslationDataSource? khaya,
    MockTranslationDataSource? mock,
  })  : _khaya = khaya ?? KhayaTranslationDataSource(),
        _mock = mock ?? MockTranslationDataSource();

  final KhayaTranslationDataSource _khaya;
  final MockTranslationDataSource _mock;

  @override
  Future<String> translate({
    required String text,
    required SupportedLanguage from,
    required SupportedLanguage to,
    required TranslationDomain domain,
  }) async {
    final hasKey = await _khaya.hasApiKey;
    if (!hasKey) {
      return _mock.translate(text: text, from: from, to: to, domain: domain);
    }
    // Let KhayaApiException propagate — see class doc for why.
    return _khaya.translate(text: text, from: from, to: to, domain: domain);
  }
}
