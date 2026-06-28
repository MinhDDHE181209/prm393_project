import 'package:sqflite/sqflite.dart';
import '../app/constants.dart';
import '../models/user_progress.dart';
import 'database_helper.dart';

class ProgressService {
  final _dbHelper = DatabaseHelper.instance;

  /// Lấy progress của user, tạo mới nếu chưa có.
  Future<UserProgress> getProgress(String userId) async {
    final db = await _dbHelper.database;
    // ✅ FIX: where dùng đúng column name 'user_id'
    final maps = await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) {
      final newProgress = UserProgress(userId: userId);
      await db.insert('user_progress', newProgress.toMap());
      return newProgress;
    }
    return UserProgress.fromMap(maps.first);
  }

  /// Cộng XP và tự động tính level mới.
  Future<UserProgress> addXP(String userId, int amount) async {
    final db = await _dbHelper.database;
    final current = await getProgress(userId);
    final newXP = current.totalXP + amount;
    final newLevel = UserProgress.levelFromXP(newXP);
    final updated = current.copyWith(totalXP: newXP, level: newLevel);
    // ✅ FIX: where dùng đúng column name 'user_id'
    await db.update(
      'user_progress',
      updated.toMap(),
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return updated;
  }

  /// ✅ FIX: thêm method incrementModelsCompleted mà fold_step_screen.dart gọi
  Future<UserProgress> incrementModelsCompleted(String userId) async {
    final db = await _dbHelper.database;
    final current = await getProgress(userId);
    final updated = current.copyWith(
      modelsCompleted: current.modelsCompleted + 1,
    );
    await db.update(
      'user_progress',
      updated.toMap(),
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return updated;
  }

  /// Cập nhật streak — gọi mỗi khi hoàn thành 1 mẫu gấp.
  Future<UserProgress> updateStreak(String userId) async {
    final db = await _dbHelper.database;
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
        newStreak = current.streak;
      } else if (diff == 1) {
        newStreak = current.streak + 1;
      } else {
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
      where: 'user_id = ?',
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
    final db = await _dbHelper.database;
    await db.update(
      'user_progress',
      updated.toMap(),
      where: 'user_id = ?',
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
    final db = await _dbHelper.database;
    await db.insert(
      'sessions',
      {
        'user_id': userId,
        'model_id': modelId,
        'current_step': currentStep,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ FIX: signature nhất quán — nhận cả userId lẫn modelId
  Future<void> clearSession({
    required String userId,
    required String modelId,
  }) async {
    final db = await _dbHelper.database;
    await db.delete(
      'sessions',
      where: 'user_id = ? AND model_id = ?',
      whereArgs: [userId, modelId],
    );
  }

  /// Lấy session đang dở (dùng cho thẻ "Tiếp tục gấp" ở Home).
  Future<Map<String, dynamic>?> getLastSession(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return maps.isEmpty ? null : maps.first;
  }
}
