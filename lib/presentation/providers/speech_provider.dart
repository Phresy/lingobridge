import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/speech/speech_service.dart';
import '../../data/datasources/speech/smart_tts_service.dart';
import 'speech_settings_provider.dart';

// Speech Service Provider (For STT)
final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());

// Smart TTS Provider (For Audio + TTS fallback)
final smartTtsProvider = Provider<SmartTtsService>((ref) => SmartTtsService());

// ---- Speech-to-text (voice input) ----

class SttState {
  const SttState({
    this.isListening = false,
    this.transcript = '',
    this.error,
  });

  final bool isListening;
  final String transcript;
  final String? error;

  SttState copyWith({
    bool? isListening,
    String? transcript,
    String? error,
    bool clearError = false,
  }) {
    return SttState(
      isListening: isListening ?? this.isListening,
      transcript: transcript ?? this.transcript,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SttController extends StateNotifier<SttState> {
  SttController(this._service) : super(const SttState());

  final SpeechService _service;

  Future<void> start(SupportedLanguage language) async {
    state = state.copyWith(transcript: '', clearError: true);
    try {
      final started = await _service.startListening(
        language: language,
        onResult: (text, isFinal) {
          state = state.copyWith(transcript: text, isListening: !isFinal);
        },
      );
      if (started) {
        state = state.copyWith(isListening: true);
      } else {
        state = state.copyWith(
          isListening: false,
          error: 'Speech recognition isn\'t available on this device.',
        );
      }
    } on SpeechPermissionDeniedException {
      state = state.copyWith(
        isListening: false,
        error: 'Microphone permission is needed for voice input.',
      );
    }
  }

  Future<void> stop() async {
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }
}

final sttControllerProvider =
    StateNotifierProvider.autoDispose<SttController, SttState>(
  (ref) => SttController(ref.watch(speechServiceProvider)),
);

// ---- Text-to-speech (result playback with audio + TTS fallback) ----

enum PlaybackState { idle, playing, paused }

class TtsController extends StateNotifier<PlaybackState> {
  TtsController(this._smartTts) : super(PlaybackState.idle);

  final SmartTtsService _smartTts;
  double rate = 0.5;
  String? _currentText;
  String? _currentLanguageCode;

  Future<void> play(String text, {required String languageCode}) async {
    _currentText = text;
    _currentLanguageCode = languageCode;

    state = PlaybackState.playing;
    await _smartTts.speak(
      text: text,
      languageCode: languageCode,
      rate: rate,
    );
    state = PlaybackState.idle;
  }

  Future<void> pause() async {
    await _smartTts.pause();
    state = PlaybackState.paused;
  }

  Future<void> stop() async {
    await _smartTts.stop();
    state = PlaybackState.idle;
  }

  Future<void> replay() async {
    if (_currentText != null && _currentLanguageCode != null) {
      await play(_currentText!, languageCode: _currentLanguageCode!);
    }
  }

  Future<void> setRate(double newRate) async {
    rate = newRate;
    await _smartTts.setRate(newRate);
  }

  @override
  void dispose() {
    _smartTts.dispose();
    super.dispose();
  }
}

final ttsControllerProvider =
    StateNotifierProvider.autoDispose<TtsController, PlaybackState>(
  (ref) {
    final controller = TtsController(ref.watch(smartTtsProvider));
    controller.rate = ref.read(speechSettingsProvider).speed;
    return controller;
  },
);
