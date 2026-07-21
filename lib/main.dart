import 'package:flutter/foundation.dart' show kIsWeb; // ← ADD THIS
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';

void main() {
  // Initialize SQLite for desktop ONLY (not web)
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    const ProviderScope(
      child: LingoBridgeApp(),
    ),
  );
}
