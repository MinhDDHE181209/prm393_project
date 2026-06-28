import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/vocabulary.dart';

class VocabService {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<void> saveWord({
    required String userId,
    required String kanji,
    required String romaji,
    required String meaningVi,
    required String modelId,
  }) async {
    final db = await _db;
    await db.insert(
      'saved_words',
      {
        'user_id':      userId,
        'kanji':        kanji,
        'romaji':       romaji,
        'meaning_vi':   meaningVi,
        'model_id':     modelId,
        'needs_review': 1,
        'saved_at':     DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeWord({required String userId, required String kanji}) async {
    final db = await _db;
    await db.delete('saved_words',
        where: 'user_id = ? AND kanji = ?', whereArgs: [userId, kanji]);
  }

  Future<List<VocabWord>> getWords(String userId) async {
    final db   = await _db;
    final rows = await db.query('saved_words',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'saved_at DESC');
    return rows.map(VocabWord.fromMap).toList();
  }

  Future<List<VocabWord>> getWordsNeedingReview(String userId) async {
    final db   = await _db;
    final rows = await db.query('saved_words',
        where: 'user_id = ? AND needs_review = 1',
        whereArgs: [userId],
        orderBy: 'saved_at ASC');
    return rows.map(VocabWord.fromMap).toList();
  }

  Future<void> markReviewed({required String userId, required String kanji}) async {
    final db = await _db;
    await db.update('saved_words', {'needs_review': 0},
        where: 'user_id = ? AND kanji = ?', whereArgs: [userId, kanji]);
  }

  Future<void> markNeedsReview({required String userId, required String kanji}) async {
    final db = await _db;
    await db.update('saved_words', {'needs_review': 1},
        where: 'user_id = ? AND kanji = ?', whereArgs: [userId, kanji]);
  }

  Future<int> countWords(String userId) async {
    final db     = await _db;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM saved_words WHERE user_id = ?', [userId]);
    return (result.first['cnt'] as int?) ?? 0;
  }
}