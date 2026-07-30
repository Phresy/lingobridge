// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Smart TTS Service - uses pre-recorded audio when available, falls back to system TTS
class SmartTtsService {
  SmartTtsService() {
    _initialize();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  // Cache to track which audio files exist
  final Map<String, bool> _audioCache = {};

  Future<void> _initialize() async {
    try {
      await rootBundle.loadString('assets/audio/manifest.json');
    } catch (e) {
      // No manifest - we'll check files on-demand
    }
  }

  /// Speak text - uses audio if available, falls back to TTS
  Future<void> speak({
    required String text,
    required String languageCode,
    double rate = 0.5,
    String? gender, // ← ADDED: 'male' or 'female'
  }) async {
    if (text.isEmpty) return;

    final fileName = _sanitizeFileName(text);
    final audioPath = 'assets/audio/$languageCode/$fileName.mp3';

    print('🔊 Attempting to play: $audioPath');

    // Try to play pre-recorded audio
    if (await _hasAudio(audioPath)) {
      print('✅ Playing pre-recorded audio');
      await _playAudio(audioPath);
      return;
    }

    // Fallback to system TTS
    print('⚠️ No audio found, using system TTS');
    await _speakTts(text, languageCode, rate, gender);
  }

  /// Check if audio file exists
  Future<bool> _hasAudio(String path) async {
    if (_audioCache.containsKey(path)) {
      return _audioCache[path]!;
    }

    try {
      await rootBundle.load(path);
      _audioCache[path] = true;
      print('✅ Audio found: $path');
      return true;
    } catch (e) {
      _audioCache[path] = false;
      print('❌ Audio not found: $path');
      return false;
    }
  }

  /// Play pre-recorded audio
  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  /// System TTS fallback with gender support
  Future<void> _speakTts(
    String text,
    String languageCode,
    double rate,
    String? gender,
  ) async {
    try {
      final lang = _getTtsLanguage(languageCode);
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(rate);

      // Set voice gender if specified
      if (gender != null) {
        await _tts.setVoice({
          'name': gender == 'female' ? 'Female Voice' : 'Male Voice',
          'locale': lang,
        });
      }

      await _tts.speak(text);
    } catch (e) {
      print('❌ TTS error: $e');
    }
  }

  /// Convert our language code to TTS language code
  String _getTtsLanguage(String languageCode) {
    switch (languageCode) {
      case 'tw':
        return 'tw'; // Twi
      case 'ee':
        return 'ee'; // Ewe
      case 'ha':
        return 'ha'; // Hausa
      case 'gaa':
        return 'gaa'; // Ga
      default:
        return 'en'; // English
    }
  }

  /// Clean text for filename
  String _sanitizeFileName(String text) {
    return text
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_');
  }

  /// Set TTS rate
  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _tts.stop();
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    await _tts.stop();
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
