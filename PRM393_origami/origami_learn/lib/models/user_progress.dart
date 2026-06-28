import 'dart:convert';

class UserProgress {
  final String userId;
  final int totalXP;
  final int level;
  final int streak;
  final DateTime? lastFoldDate;
  final List<String> unlockedCollections;

  const UserProgress({
    required this.userId,
    this.totalXP = 0,
    this.level = 1,
    this.streak = 0,
    this.lastFoldDate,
    this.unlockedCollections = const [],
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] as String,
      totalXP: map['totalXP'] as int,
      level: map['level'] as int,
      streak: map['streak'] as int,
      lastFoldDate: map['lastFoldDate'] != null
          ? DateTime.parse(map['lastFoldDate'] as String)
          : null,
      unlockedCollections:
          List<String>.from(jsonDecode(map['unlockedCollections'] as String)),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'totalXP': totalXP,
        'level': level,
        'streak': streak,
        'lastFoldDate': lastFoldDate?.toIso8601String(),
        'unlockedCollections': jsonEncode(unlockedCollections),
      };

  UserProgress copyWith({
    int? totalXP,
    int? level,
    int? streak,
    DateTime? lastFoldDate,
    List<String>? unlockedCollections,
  }) {
    return UserProgress(
      userId: userId,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lastFoldDate: lastFoldDate ?? this.lastFoldDate,
      unlockedCollections: unlockedCollections ?? this.unlockedCollections,
    );
  }

  /// Level tính theo mỗi 200 XP
  static int levelFromXP(int xp) => (xp ~/ 200) + 1;

  /// XP cần để lên level tiếp theo
  int get xpToNextLevel => (level * 200) - totalXP;
}