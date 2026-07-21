import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

class AuthApiException implements Exception {
  AuthApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Talks to LingoBridge's own FastAPI backend — NOT Khaya. This is the
/// concrete implementation the spec's "Phase 3: wire JWT auth to a live
/// backend" asks for. The backend itself is a separate deliverable (see
/// `/backend` contract in the README); this client assumes it implements
/// exactly these three routes.
///
/// Contract:
///   POST /auth/register  { email, password }        -> { access_token, refresh_token }
///   POST /auth/login     { email, password }         -> { access_token, refresh_token }
///   POST /auth/refresh   { refresh_token }            -> { access_token, refresh_token }
///
/// All error responses are expected as { "detail": "human readable message" },
/// matching FastAPI's default HTTPException shape.
class AuthApiClient {
  AuthApiClient({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _tokensFrom(response.data);
    } on DioException catch (e) {
      throw AuthApiException(_messageFrom(e));
    }
  }

  Future<AuthTokens> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password},
      );
      return _tokensFrom(response.data);
    } on DioException catch (e) {
      throw AuthApiException(_messageFrom(e));
    }
  }

  AuthTokens _tokensFrom(dynamic data) {
    return AuthTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  String _messageFrom(DioException e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    if (detail is String) return detail;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Check your connection or try again later.';
    }
    return 'Something went wrong. Please try again.';
  }
}
