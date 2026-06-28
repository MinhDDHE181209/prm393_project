import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../app/constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(path, version: AppConstants.dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_words (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      TEXT    NOT NULL,
        kanji        TEXT    NOT NULL,
        romaji       TEXT    NOT NULL,
        meaning_vi   TEXT    NOT NULL,
        model_id     TEXT    NOT NULL,
        needs_review INTEGER NOT NULL DEFAULT 1,
        saved_at     INTEGER NOT NULL,
        UNIQUE(user_id, kanji)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        user_id           TEXT    PRIMARY KEY,
        xp                INTEGER NOT NULL DEFAULT 0,
        level             INTEGER NOT NULL DEFAULT 1,
        streak            INTEGER NOT NULL DEFAULT 0,
        last_session_date INTEGER,
        models_completed  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        user_id      TEXT    NOT NULL,
        model_id     TEXT    NOT NULL,
        current_step INTEGER NOT NULL DEFAULT 0,
        updated_at   INTEGER NOT NULL,
        PRIMARY KEY(user_id, model_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE unlocked_collections (
        user_id       TEXT    NOT NULL,
        collection_id TEXT    NOT NULL,
        unlocked_at   INTEGER NOT NULL,
        PRIMARY KEY(user_id, collection_id)
      )
    ''');
  }
}