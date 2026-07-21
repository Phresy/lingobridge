import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

enum SpeechGender { male, female }

class SpeechSettings {
  const SpeechSettings({this.speed = 0.5, this.gender = SpeechGender.female});
  final double speed; // 0.25–1.0, matches flutter_tts's setSpeechRate range
  final SpeechGender gender;

  SpeechSettings copyWith({double? speed, SpeechGender? gender}) =>
      SpeechSettings(speed: speed ?? this.speed, gender: gender ?? this.gender);
}

/// Persisted defaults for voice playback. `TtsController` (in
/// `speech_provider.dart`) reads this once on creation to seed its rate —
/// kept as two separate providers rather than one merged notifier because
/// the *default* (Settings) and the *live, per-playback* (result card
/// speed slider) values are conceptually different: changing the default
/// shouldn't retroactively alter a translation you're already listening
/// to.
class SpeechSettingsNotifier extends StateNotifier<SpeechSettings> {
  SpeechSettingsNotifier() : super(const SpeechSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SpeechSettings(
      speed: prefs.getDouble(StorageKeys.speechSpeed) ?? 0.5,
      gender: (prefs.getString(StorageKeys.speechGender) == 'male')
          ? SpeechGender.male
          : SpeechGender.female,
    );
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(StorageKeys.speechSpeed, speed);
  }

  Future<void> setGender(SpeechGender gender) async {
    state = state.copyWith(gender: gender);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.speechGender, gender.name);
  }
}

final speechSettingsProvider =
    StateNotifierProvider<SpeechSettingsNotifier, SpeechSettings>(
  (ref) => SpeechSettingsNotifier(),
);
