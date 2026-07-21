import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/app_constants.dart';
import 'translation_data_source.dart';

class KhayaApiException implements Exception {
  KhayaApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Real client for GhanaNLP's Khaya AI translation API
/// (https://translation.ghananlp.org — developer portal at
/// https://translation.ghananlp.org/apis).
///
/// IMPORTANT — verify before shipping: Khaya is a third-party Azure API
/// Management service. This client is built from their published Python
/// example (`POST https://translation-api.ghananlp.org/v1/translate` with
/// header `Ocp-Apim-Subscription-Key` and body `{"in": text, "lang":
/// "en-tw"}`). The exact response field names weren't publicly documented
/// at the time this was written, so `_extractTranslation` below tries the
/// common shapes defensively. **Confirm the real response shape against
/// your subscription in the Khaya developer portal's "Test" tab and adjust
/// `_extractTranslation` if needed** — that's a five-minute check once you
/// have a subscription key, versus guessing here.
///
/// Subscription key is entered by the user in Settings > Khaya API Key and
/// stored in secure storage — never hard-code it.
class KhayaTranslationDataSource implements TranslationDataSource {
  KhayaTranslationDataSource({Dio? dio, FlutterSecureStorage? secureStorage})
      : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _baseUrl = 'https://translation-api.ghananlp.org/v1';
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  Future<String?> get _apiKey =>
      _secureStorage.read(key: StorageKeys.khayaApiKey);

  Future<bool> get hasApiKey async {
    final key = await _apiKey;
    return key != null && key.trim().isNotEmpty;
  }

  @override
  Future<String> translate({
    required String text,
    required SupportedLanguage from,
    required SupportedLanguage to,
    required TranslationDomain domain,
  }) async {
    final key = await _apiKey;
    if (key == null || key.trim().isEmpty) {
      throw KhayaApiException(
        'No Khaya API key configured. Add one in Settings.',
      );
    }

    // Khaya's translation is English-bridged today (matches the spec's
    // "Future: language-to-language without English as the bridge" note —
    // that's explicitly out of scope until Khaya itself supports it).
    if (from != SupportedLanguage.english && to != SupportedLanguage.english) {
      throw KhayaApiException(
        'Direct ${from.displayName} → ${to.displayName} translation isn\'t '
        'supported yet — Khaya currently bridges through English.',
      );
    }

    final langPair = '${from.code}-${to.code}';

    try {
      final response = await _dio.post(
        '$_baseUrl/translate',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Ocp-Apim-Subscription-Key': key,
        }),
        data: {'in': text, 'lang': langPair},
      );
      return _extractTranslation(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw KhayaApiException(
          'Khaya API rejected the subscription key. Check it in Settings.',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw KhayaApiException(
            'Could not reach Khaya API. Check your connection.');
      }
      throw KhayaApiException('Khaya translation failed. Please try again.');
    }
  }

  /// Defensive parsing — see class doc. Handles a plain string body, or a
  /// map with a `translation`/`output`/`out` key, since Azure APIM
  /// backends for this kind of endpoint commonly return one of these.
  String _extractTranslation(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      for (final key in ['translation', 'output', 'out', 'result']) {
        final value = data[key];
        if (value is String) return value;
      }
    }
    throw KhayaApiException(
      'Unexpected response from Khaya API. See KhayaTranslationDataSource '
      'doc comment to adjust response parsing.',
    );
  }
}
