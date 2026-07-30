// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingobridge/core/constants/app_constants.dart';
import 'package:lingobridge/presentation/screens/home/home_shell.dart';
import 'package:lingobridge/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:lingobridge/presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      // If user goes to root '/', redirect to splash
      if (loc == '/') return '/splash';

      // Always show splash first
      if (loc == '/splash') return null;

      // Check if onboarding is complete
      final prefs = await SharedPreferences.getInstance();
      final onboarded = prefs.getBool(StorageKeys.onboardingComplete) ?? false;

      // If not onboarded, show onboarding
      if (!onboarded && loc != '/onboarding') return '/onboarding';

      // If onboarded and trying to go to onboarding, go to home
      if (onboarded && loc == '/onboarding') return '/home';

      // If onboarded and not on onboarding, go to home
      if (onboarded) return null;

      return null;
    },
    routes: [
      // Root route - redirect to splash
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
      // Splash Screen - shows first
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      // Onboarding Screen - shows after splash (once)
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      // Home Screen - main app
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeShell(),
      ),
    ],
  );
});
