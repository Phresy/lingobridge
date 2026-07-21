import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// One Dio instance for all calls to LingoBridge's own FastAPI backend
/// (auth, and later any server-proxied endpoints). Khaya's API is called
/// directly from the app (see `khaya_translation_data_source.dart`) since
/// it's a public third-party API, not "our" backend — so it does NOT go
/// through this client; it has its own lightweight Dio instance with its
/// own subscription-key header instead of a JWT.
///
/// The refresh-on-401 interceptor lives here, once, so no individual
/// repository has to remember to handle token expiry.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_dio, _secureStorage));
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._secureStorage);

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: StorageKeys.jwtAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRetry = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized || isRetry || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken =
          await _secureStorage.read(key: StorageKeys.jwtRefreshToken);
      if (refreshToken == null) {
        handler.next(err);
        return;
      }

      // Contract with the backend: POST /auth/refresh { refresh_token }
      // -> { access_token, refresh_token }
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;

      await _secureStorage.write(
          key: StorageKeys.jwtAccessToken, value: newAccess);
      await _secureStorage.write(
          key: StorageKeys.jwtRefreshToken, value: newRefresh);

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess'
        ..extra['retried'] = true;
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      // Refresh failed — surface the original 401 so AuthNotifier can log
      // the user out rather than looping forever.
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
