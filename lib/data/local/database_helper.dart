import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Why a hand-rolled singleton instead of a package like `drift`: the spec
/// asks for a straightforward offline SQLite store (history, packs,
/// settings, favourites), not a reactive query layer. sqflite is enough,
/// and keeping this thin means Phase 4's "downloaded language packs" table
/// is just one more `CREATE TABLE` here, not a schema-generation step.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _dbName = 'lingobridge.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE translations (
        id TEXT PRIMARY KEY,
        source_text TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_language TEXT NOT NULL,
        domain TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_translations_created_at ON translations(created_at)',
    );

    // Phase 4 will add a `language_packs` table here (id, language,
    // version, size_bytes, downloaded_at, local_path) once model
    // downloads are implemented — schema versioning via onUpgrade at that
    // point, so existing user data isn't lost.
  }
}
