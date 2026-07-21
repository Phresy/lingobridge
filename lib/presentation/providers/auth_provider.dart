import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/auth/auth_api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.isGuest = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;
  final bool isGuest;
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    bool? isGuest,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Real login/register now hit the FastAPI backend via [AuthApiClient] and
/// store genuine JWTs. Guest mode is kept as a deliberate, clearly-labeled
/// local-only path (no backend call, no sync) rather than removed — the
/// spec's target users include people who may be offline or unwilling to
/// register, and LingoBridge's whole premise is working without a network.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? AuthApiClient(),
        super(const AuthState()) {
    _restoreSession();
  }

  final AuthApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  Future<void> _restoreSession() async {
    final token = await _secureStorage.read(key: StorageKeys.jwtAccessToken);
    if (token == null || JwtDecoder.isExpired(token)) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    final decoded = JwtDecoder.decode(token);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: decoded['sub'] as String?,
      email: decoded['email'] as String?,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final tokens = await _apiClient.login(email: email, password: password);
      await _persistAndSetAuthenticated(tokens, email: email);
    } on AuthApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final tokens =
          await _apiClient.register(email: email, password: password);
      await _persistAndSetAuthenticated(tokens, email: email);
    } on AuthApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    }
  }

  Future<void> _persistAndSetAuthenticated(
    AuthTokens tokens, {
    required String email,
  }) async {
    await _secureStorage.write(
        key: StorageKeys.jwtAccessToken, value: tokens.accessToken);
    await _secureStorage.write(
        key: StorageKeys.jwtRefreshToken, value: tokens.refreshToken);
    final decoded = JwtDecoder.decode(tokens.accessToken);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: decoded['sub'] as String? ?? decoded['user_id'] as String?,
      email: email,
      isGuest: false,
      isSubmitting: false,
    );
  }

  /// Local-only session — no backend call. History still saves locally via
  /// SQLite; the only thing guests lose is cross-device sync (a future,
  /// backend-backed feature this same AuthState.isGuest flag will gate).
  void continueAsGuest() {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      isGuest: true,
      email: null,
      userId: 'guest',
      isSubmitting: false,
      clearError: true,
    );
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.jwtAccessToken);
    await _secureStorage.delete(key: StorageKeys.jwtRefreshToken);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
