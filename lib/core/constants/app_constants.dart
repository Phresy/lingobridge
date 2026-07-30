library;

import 'package:flutter/material.dart';

enum SupportedLanguage {
  english,
  twi,
  ewe,
  ga,
  hausa,
  dagbani // ← ADDED
}

extension SupportedLanguageX on SupportedLanguage {
  /// ISO-ish code used as the key for API calls and local DB rows.
  String get code {
    switch (this) {
      case SupportedLanguage.english:
        return 'en';
      case SupportedLanguage.twi:
        return 'tw';
      case SupportedLanguage.ewe:
        return 'ee';
      case SupportedLanguage.ga:
        return 'gaa';
      case SupportedLanguage.hausa:
        return 'ha';
      case SupportedLanguage.dagbani: // ← ADDED
        return 'dag';
    }
  }

  String get displayName {
    switch (this) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.twi:
        return 'Twi (Akan)';
      case SupportedLanguage.ewe:
        return 'Ewe';
      case SupportedLanguage.ga:
        return 'Ga';
      case SupportedLanguage.hausa:
        return 'Hausa';
      case SupportedLanguage.dagbani: // ← ADDED
        return 'Dagbani';
    }
  }

  /// Approximate on-device language-pack size, shown in the Downloads screen.
  String get packSizeLabel {
    switch (this) {
      case SupportedLanguage.english:
        return '—';
      case SupportedLanguage.twi:
        return '~180 MB';
      case SupportedLanguage.ewe:
        return '~175 MB';
      case SupportedLanguage.ga:
        return '~170 MB';
      case SupportedLanguage.hausa:
        return '~190 MB';
      case SupportedLanguage.dagbani: // ← ADDED
        return '~160 MB';
    }
  }
}

enum TranslationDomain {
  general,
  agriculture,
  education,
  healthcare,
  legal,
  business
}

extension TranslationDomainX on TranslationDomain {
  String get label {
    switch (this) {
      case TranslationDomain.general:
        return 'General';
      case TranslationDomain.agriculture:
        return 'Agriculture';
      case TranslationDomain.education:
        return 'Education';
      case TranslationDomain.healthcare:
        return 'Healthcare';
      case TranslationDomain.legal:
        return 'Legal';
      case TranslationDomain.business:
        return 'Business';
    }
  }

  IconData get icon {
    switch (this) {
      case TranslationDomain.general:
        return Icons.translate_outlined;
      case TranslationDomain.agriculture:
        return Icons.grass_outlined;
      case TranslationDomain.education:
        return Icons.school_outlined;
      case TranslationDomain.healthcare:
        return Icons.medical_services_outlined;
      case TranslationDomain.legal:
        return Icons.gavel_outlined;
      case TranslationDomain.business:
        return Icons.business_outlined;
    }
  }
}

class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.lingobridge.app/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}

class StorageKeys {
  StorageKeys._();

  static const String jwtAccessToken = 'lb_access_token';
  static const String jwtRefreshToken = 'lb_refresh_token';
  static const String onboardingComplete = 'lb_onboarding_complete';
  static const String themeMode = 'lb_theme_mode';
  static const String fontScale = 'lb_font_scale';
  static const String speechSpeed = 'lb_speech_speed';
  static const String speechGender = 'lb_speech_gender';
  static const String autoDetectLanguage = 'lb_auto_detect_language';
  static const String themeColorSeed = 'lb_theme_color_seed';
  static const String khayaApiKey = 'lb_khaya_api_key';
}
