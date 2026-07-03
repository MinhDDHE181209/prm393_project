import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/vocabulary.dart';
import '../untils/sm2_algorithm.dart';

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
    final now = DateTime.now();
    await db.insert(
      'saved_words',
      {
        'user_id': userId,
        'kanji': kanji,
        'romaji': romaji,
        'meaning_vi': meaningVi,
        'model_id': modelId,
        'needs_review': 1,
        'saved_at': now.millisecondsSinceEpoch,
        'repetitions': 0,
        'ease_factor': 2.5,
        'interval_days': 0,
        'next_review_at': now.millisecondsSinceEpoch,
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
    final db = await _db;
    final rows = await db.query('saved_words',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'saved_at DESC');
    return rows.map(VocabWord.fromMap).toList();
  }

  Future<VocabWord?> _getWord({
    required String userId,
    required String kanji,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'saved_words',
      where: 'user_id = ? AND kanji = ?',
      whereArgs: [userId, kanji],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return VocabWord.fromMap(rows.first);
  }

  Future<List<VocabWord>> getWordsNeedingReview(String userId) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query(
      'saved_words',
      where: 'user_id = ? AND (needs_review = 1 OR next_review_at <= ?)',
      whereArgs: [userId, now],
      orderBy: 'next_review_at ASC',
    );
    return rows.map(VocabWord.fromMap).toList();
  }

  /// Ghi nhận kết quả ôn tập qua SM-2.
  ///
  /// [quality] 0–5 theo chuẩn SuperMemo (≥3 = đúng).
  Future<SM2Result> markReviewed({
    required String userId,
    required String kanji,
    required int quality,
  }) async {
    assert(quality >= 0 && quality <= 5);

    final word = await _getWord(userId: userId, kanji: kanji);
    if (word == null) {
      throw StateError('Từ "$kanji" không tồn tại trong Word Vault');
    }

    final result = SM2Algorithm.calculate(
      quality: quality,
      repetitions: word.repetitions,
      easeFactor: word.easeFactor,
      interval: word.intervalDays,
    );

    final needsReview = SM2Algorithm.isDue(result.nextReviewAt) ? 1 : 0;

    final db = await _db;
    await db.update(
      'saved_words',
      {
        'repetitions': result.repetitions,
        'ease_factor': result.easeFactor,
        'interval_days': result.interval,
        'next_review_at': result.nextReviewAt.millisecondsSinceEpoch,
        'needs_review': needsReview,
      },
      where: 'user_id = ? AND kanji = ?',
      whereArgs: [userId, kanji],
    );

    return result;
  }

  /// Đặt lại từ về trạng thái cần ôn ngay.
  Future<void> markNeedsReview({required String userId, required String kanji}) async {
    final db = await _db;
    final now = DateTime.now();
    await db.update(
      'saved_words',
      {
        'needs_review': 1,
        'repetitions': 0,
        'interval_days': 0,
        'ease_factor': 2.5,
        'next_review_at': now.millisecondsSinceEpoch,
      },
      where: 'user_id = ? AND kanji = ?',
      whereArgs: [userId, kanji],
    );
  }

  Future<int> countWords(String userId) async {
    final db = await _db;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM saved_words WHERE user_id = ?', [userId]);
    return (result.first['cnt'] as int?) ?? 0;
  }
}
