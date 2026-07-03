import '../untils/sm2_algorithm.dart';

class VocabWord {
  final int? id;
  final String userId;
  final String kanji;
  final String romaji;
  final String meaningVi;
  final String modelId;
  final bool needsReview;
  final DateTime savedAt;

  // SM-2 spaced repetition fields
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewAt;

  const VocabWord({
    this.id,
    required this.userId,
    required this.kanji,
    required this.romaji,
    required this.meaningVi,
    required this.modelId,
    required this.needsReview,
    required this.savedAt,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    required this.nextReviewAt,
  });

  /// Từ có cần ôn hôm nay không (ưu tiên SM-2, fallback cờ needsReview).
  bool get isDueForReview =>
      needsReview || SM2Algorithm.isDue(nextReviewAt);

  factory VocabWord.fromMap(Map<String, dynamic> map) {
    final savedAt = DateTime.fromMillisecondsSinceEpoch(map['saved_at'] as int);
    return VocabWord(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      kanji: map['kanji'] as String,
      romaji: map['romaji'] as String,
      meaningVi: map['meaning_vi'] as String,
      modelId: map['model_id'] as String,
      needsReview: (map['needs_review'] as int) == 1,
      savedAt: savedAt,
      repetitions: (map['repetitions'] as int?) ?? 0,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (map['interval_days'] as int?) ?? 0,
      nextReviewAt: map['next_review_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['next_review_at'] as int)
          : savedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'kanji': kanji,
        'romaji': romaji,
        'meaning_vi': meaningVi,
        'model_id': modelId,
        'needs_review': needsReview ? 1 : 0,
        'saved_at': savedAt.millisecondsSinceEpoch,
        'repetitions': repetitions,
        'ease_factor': easeFactor,
        'interval_days': intervalDays,
        'next_review_at': nextReviewAt.millisecondsSinceEpoch,
      };

  VocabWord copyWith({
    bool? needsReview,
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewAt,
  }) =>
      VocabWord(
        id: id,
        userId: userId,
        kanji: kanji,
        romaji: romaji,
        meaningVi: meaningVi,
        modelId: modelId,
        needsReview: needsReview ?? this.needsReview,
        savedAt: savedAt,
        repetitions: repetitions ?? this.repetitions,
        easeFactor: easeFactor ?? this.easeFactor,
        intervalDays: intervalDays ?? this.intervalDays,
        nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      );
}
