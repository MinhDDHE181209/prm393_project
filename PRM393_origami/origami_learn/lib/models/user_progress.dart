import 'dart:convert';

class UserProgress {
  final String userId;
  final int totalXP;
  final int level;
  final int streak;
  final DateTime? lastFoldDate;
  final List<String> unlockedCollections;
  final int modelsCompleted;

  const UserProgress({
    required this.userId,
    this.totalXP = 0,
    this.level = 1,
    this.streak = 0,
    this.lastFoldDate,
    this.unlockedCollections = const [],
    this.modelsCompleted = 0,
  });

  // ✅ FIX: keys khớp với column names trong DB (snake_case)
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['user_id'] as String,
      totalXP: map['total_xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      streak: map['streak'] as int? ?? 0,
      lastFoldDate: map['last_fold_date'] != null
          ? DateTime.tryParse(map['last_fold_date'] as String)
          : null,
      unlockedCollections: List<String>.from(
          jsonDecode(map['unlocked_collections'] as String? ?? '[]')),
      modelsCompleted: map['models_completed'] as int? ?? 0,
    );
  }

  // ✅ FIX: keys khớp với column names trong DB (snake_case)
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'total_xp': totalXP,
        'level': level,
        'streak': streak,
        'last_fold_date': lastFoldDate?.toIso8601String(),
        'unlocked_collections': jsonEncode(unlockedCollections),
        'models_completed': modelsCompleted,
      };

  UserProgress copyWith({
    int? totalXP,
    int? level,
    int? streak,
    DateTime? lastFoldDate,
    List<String>? unlockedCollections,
    int? modelsCompleted,
  }) {
    return UserProgress(
      userId: userId,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lastFoldDate: lastFoldDate ?? this.lastFoldDate,
      unlockedCollections: unlockedCollections ?? this.unlockedCollections,
      modelsCompleted: modelsCompleted ?? this.modelsCompleted,
    );
  }

  static int levelFromXP(int xp) => (xp ~/ 200) + 1;

  int get xpToNextLevel => (level * 200) - totalXP;

  // XP trong level hiện tại (dùng cho progress bar)
  int get xpInCurrentLevel => totalXP - ((level - 1) * 200);

  // % hoàn thành level hiện tại (0.0 – 1.0)
  double get levelProgress => (xpInCurrentLevel / 200).clamp(0.0, 1.0);
}
