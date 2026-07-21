import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingobridge/core/constants/app_constants.dart';
import 'package:lingobridge/presentation/providers/auth_provider.dart';
import 'package:lingobridge/presentation/screens/auth/login_screen.dart';
import 'package:lingobridge/presentation/screens/home/home_shell.dart';
import 'package:lingobridge/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:lingobridge/presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;

      final prefs = await SharedPreferences.getInstance();
      final onboarded =
          prefs.getBool(StorageKeys.onboardingComplete) ?? false;

      if (!onboarded && loc != '/onboarding') return '/onboarding';
      if (onboarded && loc == '/onboarding') return '/home';

      final loggingIn = loc == '/login';
      final authenticated = authState.status == AuthStatus.authenticated;

      if (!authenticated && !loggingIn && onboarded) return '/login';
      if (authenticated && loggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}