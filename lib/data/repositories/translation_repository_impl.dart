import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/entities/translation_entry.dart';
import '../../domain/repositories/translation_repository.dart';
import '../local/database_helper.dart';
import '../models/translation_model.dart';

class SqliteTranslationRepository implements TranslationRepository {
  SqliteTranslationRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;
  static const _table = 'translations';

  // In-memory storage for web
  final List<TranslationEntry> _webHistory = [];

  @override
  Future<List<TranslationEntry>> getHistory() async {
    if (kIsWeb) {
      return _webHistory;
    }
    final db = await _dbHelper.database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(TranslationModel.fromMap).toList();
  }

  @override
  Future<List<TranslationEntry>> getFavorites() async {
    if (kIsWeb) {
      return _webHistory.where((e) => e.isFavorite).toList();
    }
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'is_favorite = 1',
      orderBy: 'created_at DESC',
    );
    return rows.map(TranslationModel.fromMap).toList();
  }

  @override
  Future<List<TranslationEntry>> search(String query) async {
    if (query.trim().isEmpty) return getHistory();
    if (kIsWeb) {
      final like = query.trim().toLowerCase();
      return _webHistory
          .where((e) =>
              e.sourceText.toLowerCase().contains(like) ||
              e.translatedText.toLowerCase().contains(like))
          .toList();
    }
    final db = await _dbHelper.database;
    final like = '%${query.trim()}%';
    final rows = await db.query(
      _table,
      where: 'source_text LIKE ? OR translated_text LIKE ?',
      whereArgs: [like, like],
      orderBy: 'created_at DESC',
    );
    return rows.map(TranslationModel.fromMap).toList();
  }

  @override
  Future<TranslationEntry> addEntry(TranslationEntry entry) async {
    if (kIsWeb) {
      _webHistory.insert(0, entry);
      return entry;
    }
    final db = await _dbHelper.database;
    await db.insert(_table, TranslationModel(entry: entry).toMap());
    return entry;
  }

  @override
  Future<void> toggleFavorite(String id) async {
    if (kIsWeb) {
      final index = _webHistory.indexWhere((e) => e.id == id);
      if (index != -1) {
        final entry = _webHistory[index];
        _webHistory[index] = entry.copyWith(isFavorite: !entry.isFavorite);
      }
      return;
    }
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final current = (rows.first['is_favorite'] as int) == 1;
    await db.update(
      _table,
      {'is_favorite': current ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    if (kIsWeb) {
      _webHistory.removeWhere((e) => e.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearHistory() async {
    if (kIsWeb) {
      _webHistory.clear();
      return;
    }
    final db = await _dbHelper.database;
    await db.delete(_table);
  }
}
