import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PackDownloader {
  final Dio _dio = Dio();

  /// Download a language pack
  Future<void> downloadPack({
    required String languageCode,
    required String url,
    required void Function(int bytes, int total) onProgress,
    required void Function(String status) onStatus,
  }) async {
    onStatus('Starting download...');

    final dir = await _getLangPacksDir();
    final filePath = path.join(dir.path, '$languageCode.json');
    final file = File(filePath);

    await file.create(recursive: true);

    try {
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received, total);
            final percent = (received / total * 100).round();
            onStatus('Downloading... $percent%');
          }
        },
      );

      // Verify the downloaded file is valid JSON
      try {
        final content = await file.readAsString();
        json.decode(content);
        onStatus('Download complete!');
      } catch (e) {
        await file.delete();
        throw Exception('Invalid pack file: $e');
      }
    } catch (e) {
      // Clean up on error
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  /// Delete a language pack
  Future<void> deletePack(String languageCode) async {
    final dir = await _getLangPacksDir();
    final filePath = path.join(dir.path, '$languageCode.json');
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Check if a language pack is downloaded
  Future<bool> isPackDownloaded(String languageCode) async {
    final dir = await _getLangPacksDir();
    final filePath = path.join(dir.path, '$languageCode.json');
    final file = File(filePath);
    return await file.exists();
  }

  /// Get the size of a downloaded pack in bytes
  Future<int> getPackSize(String languageCode) async {
    final dir = await _getLangPacksDir();
    final filePath = path.join(dir.path, '$languageCode.json');
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Get all downloaded packs
  Future<List<String>> getDownloadedPacks() async {
    final dir = await _getLangPacksDir();
    if (!await dir.exists()) {
      return [];
    }
    final files = await dir.list().toList();
    return files
        .where((f) => f.path.endsWith('.json'))
        .map((f) => path.basenameWithoutExtension(f.path))
        .toList();
  }

  /// Get the directory for language packs
  Future<Directory> _getLangPacksDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path.join(appDir.path, 'lang_packs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
