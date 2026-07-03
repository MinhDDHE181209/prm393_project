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
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ✅ FIX: column names phải khớp với VocabWord.fromMap() / toMap()
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
        repetitions  INTEGER NOT NULL DEFAULT 0,
        ease_factor  REAL    NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 0,
        next_review_at INTEGER NOT NULL,
        UNIQUE(user_id, kanji)
      )
    ''');

    // ✅ FIX: column names khớp với UserProgress.fromMap() / toMap()
    // Dùng snake_case nhất quán, toMap() sẽ map sang đây
    await db.execute('''
      CREATE TABLE user_progress (
        user_id             TEXT    PRIMARY KEY,
        total_xp            INTEGER NOT NULL DEFAULT 0,
        level               INTEGER NOT NULL DEFAULT 1,
        streak              INTEGER NOT NULL DEFAULT 0,
        last_fold_date      TEXT,
        unlocked_collections TEXT   NOT NULL DEFAULT '[]',
        models_completed    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ✅ FIX: thêm user_id vào sessions để query đúng
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE saved_words ADD COLUMN repetitions INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE saved_words ADD COLUMN ease_factor REAL NOT NULL DEFAULT 2.5');
      await db.execute(
          'ALTER TABLE saved_words ADD COLUMN interval_days INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE saved_words ADD COLUMN next_review_at INTEGER');
      // Backfill: từ cần ôn → due ngay; đã thuộc → lùi 30 ngày
      await db.execute('''
        UPDATE saved_words
        SET next_review_at = CASE
          WHEN needs_review = 1 THEN saved_at
          ELSE saved_at + ${30 * 24 * 60 * 60 * 1000}
        END
        WHERE next_review_at IS NULL
      ''');
    }
  }
}
