import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/constants/app_constants.dart';

class SpeechPermissionDeniedException implements Exception {
  @override
  String toString() => 'Microphone permission was denied.';
}

/// Speech-to-Text only (TTS is now handled by SmartTtsService)
class SpeechService {
  SpeechService() : _speechToText = stt.SpeechToText();

  final stt.SpeechToText _speechToText;
  bool _sttInitialized = false;

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> startListening({
    required void Function(String recognizedText, bool isFinal) onResult,
    required SupportedLanguage language,
  }) async {
    if (!await _ensureMicPermission()) {
      throw SpeechPermissionDeniedException();
    }

    if (!_sttInitialized) {
      _sttInitialized = await _speechToText.initialize();
    }
    if (!_sttInitialized) return false;

    final localeId = _bestAvailableLocale(language);

    await _speechToText.listen(
      onResult: (result) =>
          onResult(result.recognizedWords, result.finalResult),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        localeId: localeId,
      ),
    );
    return true;
  }

  Future<void> stopListening() => _speechToText.stop();

  bool get isListening => _speechToText.isListening;

  String? _bestAvailableLocale(SupportedLanguage language) {
    return language == SupportedLanguage.english ? 'en_US' : null;
  }
}
