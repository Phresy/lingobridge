// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/translation_entry.dart';
import 'history_provider.dart';
import 'translation_di_provider.dart';

class TranslateState {
  const TranslateState({
    this.sourceLanguage = SupportedLanguage.english,
    this.targetLanguage = SupportedLanguage.twi,
    this.domain = TranslationDomain.general,
    this.inputText = '',
    this.result,
    this.isTranslating = false,
    this.error,
  });

  final SupportedLanguage sourceLanguage;
  final SupportedLanguage targetLanguage;
  final TranslationDomain domain;
  final String inputText;
  final TranslationEntry? result;
  final bool isTranslating;
  final String? error;

  TranslateState copyWith({
    SupportedLanguage? sourceLanguage,
    SupportedLanguage? targetLanguage,
    TranslationDomain? domain,
    String? inputText,
    TranslationEntry? result,
    bool clearResult = false,
    bool? isTranslating,
    String? error,
    bool clearError = false,
  }) {
    return TranslateState(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      domain: domain ?? this.domain,
      inputText: inputText ?? this.inputText,
      result: clearResult ? null : (result ?? this.result),
      isTranslating: isTranslating ?? this.isTranslating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TranslateController extends StateNotifier<TranslateState> {
  TranslateController(this._ref) : super(const TranslateState());

  final Ref _ref;

  void setSourceLanguage(SupportedLanguage lang) =>
      state = state.copyWith(sourceLanguage: lang, clearResult: true);

  void setTargetLanguage(SupportedLanguage lang) =>
      state = state.copyWith(targetLanguage: lang, clearResult: true);

  void setDomain(TranslationDomain domain) =>
      state = state.copyWith(domain: domain, clearResult: true);

  void setInputText(String text) =>
      state = state.copyWith(inputText: text, clearResult: true);

  void swapLanguages() {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
      clearResult: true,
    );
  }

  Future<void> translate() async {
    final text = state.inputText.trim();
    if (text.isEmpty) return;

    print('Translating: "$text"');

    state = state.copyWith(
      isTranslating: true,
      clearError: true,
      clearResult: true,
    );

    try {
      final useCase = _ref.read(translateAndSaveUseCaseProvider);
      final entry = await useCase(
        sourceText: text,
        from: state.sourceLanguage,
        to: state.targetLanguage,
        domain: state.domain,
      );

      print('Result: "${entry.translatedText}"');

      state = state.copyWith(
        result: entry,
        isTranslating: false,
        error: null,
      );

      unawaited(_ref.read(historyProvider.notifier).load());
    } catch (e, stack) {
      print('ERROR: $e');
      print('STACK: $stack');

      state = state.copyWith(
        isTranslating: false,
        error: 'Translation failed: ${e.toString()}',
        clearResult: true,
      );
    }
  }

  void toggleResultFavorite() {
    final result = state.result;
    if (result == null) return;
    _ref.read(historyProvider.notifier).toggleFavorite(result.id);
    state = state.copyWith(
      result: result.copyWith(isFavorite: !result.isFavorite),
    );
  }
}

final translateControllerProvider =
    StateNotifierProvider.autoDispose<TranslateController, TranslateState>(
  (ref) => TranslateController(ref),
);
