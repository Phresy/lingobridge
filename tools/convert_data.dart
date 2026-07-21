// ignore_for_file: unused_import, avoid_print

import 'dart:convert';
import 'dart:io';

void main() {
  print('Converting Twi...');
  convertCsv('assets/data/twi_en.csv', 'lib/core/data/twi_data.dart',
      'twiTranslations');

  print('Converting Ewe...');
  convertCsv('assets/data/ewe_en.csv', 'lib/core/data/ewe_data.dart',
      'eweTranslations');

  print('Converting Hausa...');
  convertCsv('assets/data/hausa_en.csv', 'lib/core/data/hausa_data.dart',
      'hausaTranslations');

  print('Done!');
}

void convertCsv(String inputPath, String outputPath, String variableName) {
  try {
    final file = File(inputPath);
    if (!file.existsSync()) {
      print('File not found: $inputPath');
      return;
    }

    final lines = file.readAsLinesSync();
    final map = <String, String>{};

    // Skip header and process rows
    for (var i = 1; i < lines.length && i < 10000; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      final parts = _parseCsvLine(line);
      if (parts.length >= 3) {
        String english =
            parts[1].trim().replaceAll('"', '').replaceAll("'", "\\'");
        String local =
            parts[2].trim().replaceAll('"', '').replaceAll("'", "\\'");

        if (english.isNotEmpty && local.isNotEmpty) {
          map[english] = local;
        }
      }
    }

    // Generate readable Dart file with one translation per line
    final buffer = StringBuffer();
    buffer.writeln('// Auto-generated from GhanaNLP data');
    buffer.writeln('// ${map.length} translations');
    buffer.writeln('');
    buffer.writeln('Map<String, String> $variableName = {');

    // Write each translation on its own line with proper escaping
    final entries = map.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final key = entry.key;
      final value = entry.value;
      final isLast = i == entries.length - 1;

      // Escape any special characters in the strings
      final escapedKey = key.replaceAll('"', '\\"');
      final escapedValue = value.replaceAll('"', '\\"');

      buffer.write('  "$escapedKey": "$escapedValue"');
      if (!isLast) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
    }

    buffer.writeln('};');

    File(outputPath).writeAsStringSync(buffer.toString());
    print('Converted ${map.length} translations to $outputPath');
    print('File size: ${(buffer.length / 1024).toStringAsFixed(1)} KB');
  } catch (e) {
    print('Error converting $inputPath: $e');
  }
}

/// Simple CSV line parser that handles quoted fields
List<String> _parseCsvLine(String line) {
  final result = <String>[];
  final buffer = StringBuffer();
  bool inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(buffer.toString().trim());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  result.add(buffer.toString().trim());
  return result;
}
