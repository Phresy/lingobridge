import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Stored as a plain multiplier (1.0 = default) rather than an enum like
/// {small, medium, large} so the Settings slider can offer fine-grained
/// steps without a matching Dart enum change every time the design wants
/// another size option.
class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(1.0) {
    _load();
  }

  static const double min = 0.85;
  static const double max = 1.3;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(StorageKeys.fontScale) ?? 1.0;
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(min, max);
    state = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(StorageKeys.fontScale, clamped);
  }
}

final fontScaleProvider =
    StateNotifierProvider<FontScaleNotifier, double>(
  (ref) => FontScaleNotifier(),
);
