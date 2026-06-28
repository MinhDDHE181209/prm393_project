import '../app/constants.dart';
import '../models/user_progress.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
class ProgressService {
  final _db = DatabaseHelper.instance;

  /// Lấy progress của user, tạo mới nếu chưa có.
  Future<UserProgress> getProgress(String userId) async {
    final db = await _db.database;
    final maps = await db.query(
      'user_progress',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) {
      // Tạo record mới cho user lần đầu
      final newProgress = UserProgress(userId: userId);
      await db.insert('user_progress', newProgress.toMap());
      return newProgress;
    }
    return UserProgress.fromMap(maps.first);
  }

  /// Cộng XP và tự động tính level mới.
  Future<UserProgress> addXP(String userId, int amount) async {
    final db = await _db.database;
    final current = await getProgress(userId);
    final newXP = current.totalXP + amount;
    final newLevel = UserProgress.levelFromXP(newXP);

    final updated = current.copyWith(totalXP: newXP, level: newLevel);
    await db.update(
      'user_progress',
      updated.toMap(),
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return updated;
  }

  /// Cập nhật streak — gọi mỗi khi hoàn thành 1 mẫu gấp.
  Future<UserProgress> updateStreak(String userId) async {
    final db = await _db.database;
    final current = await getProgress(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = current.streak;

    if (current.lastFoldDate == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime(
        current.lastFoldDate!.year,
        current.lastFoldDate!.month,
        current.lastFoldDate!.day,
      );
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        // Hôm nay đã gấp rồi, không tăng streak
        newStreak = current.streak;
      } else if (diff == 1) {
        // Hôm qua có gấp → streak tăng
        newStreak = current.streak + 1;
      } else {
        // Bỏ ngày → streak reset
        newStreak = 1;
      }
    }

    final updated = current.copyWith(
      streak: newStreak,
      lastFoldDate: now,
    );
    await db.update(
      'user_progress',
      updated.toMap(),
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return updated;
  }

  /// Mở khoá collection sau khi mua.
  Future<UserProgress> unlockCollection(
      String userId, String collectionId) async {
    final current = await getProgress(userId);
    if (current.unlockedCollections.contains(collectionId)) return current;

    final updated = current.copyWith(
      unlockedCollections: [...current.unlockedCollections, collectionId],
    );
    final db = await _db.database;
    await db.update(
      'user_progress',
      updated.toMap(),
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return updated;
  }

  /// Lưu tiến trình gấp dở dang.
  Future<void> saveSession({
    required String userId,
    required String modelId,
    required int currentStep,
    int currentModule = 0,
  }) async {
    final db = await _db.database;
    await db.insert(
      'session_progress',
      {
        'modelId': modelId,
        'userId': userId,
        'currentStep': currentStep,
        'currentModule': currentModule,
        'startedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Xoá session khi hoàn thành.
  Future<void> clearSession(String modelId) async {
    final db = await _db.database;
    await db.delete(
      'session_progress',
      where: 'modelId = ?',
      whereArgs: [modelId],
    );
  }

  /// Lấy session đang dở (dùng cho thẻ "Tiếp tục gấp" ở Home).
  Future<Map<String, dynamic>?> getLastSession(String userId) async {
    final db = await _db.database;
    final maps = await db.query(
      'session_progress',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startedAt DESC',
      limit: 1,
    );
    return maps.isEmpty ? null : maps.first;
  }
}