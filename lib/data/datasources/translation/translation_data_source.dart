import '../../../core/constants/app_constants.dart';

/// Both the future Khaya API client (Phase 3, online) and the future local
/// NLLB model runner (Phase 4, offline) will implement this same interface.
/// The app-flow diagram's "Internet available? → Khaya : Local NLLB" branch
/// becomes, in code, just picking which implementation of this class to
/// call — decided by `connectivityProvider`, not by scattering `if (online)`
/// checks through the UI.
abstract class TranslationDataSource {
  Future<String> translate({
    required String text,
    required SupportedLanguage from,
    required SupportedLanguage to,
    required TranslationDomain domain,
  });
}
