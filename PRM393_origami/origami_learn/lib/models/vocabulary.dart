import 'package:cloud_firestore/cloud_firestore.dart';
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

  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewAt;

  // ✅ MỚI: theo dõi đồng bộ
  final DateTime updatedAt;
  final DateTime? syncedAt;

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
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isDueForReview =>
      needsReview || SM2Algorithm.isDue(nextReviewAt);

  bool get isSynced => syncedAt != null && !syncedAt!.isBefore(updatedAt);

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
      updatedAt: map['updated_at'] != null && (map['updated_at'] as int) > 0
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : savedAt,
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int)
          : null,
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
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'synced_at': syncedAt?.millisecondsSinceEpoch,
      };

  // ✅ MỚI: mapping sang/từ Firestore
  factory VocabWord.fromFirestore(String userId, Map<String, dynamic> data) {
    return VocabWord(
      userId: userId,
      kanji: data['kanji'] as String,
      romaji: data['romaji'] as String,
      meaningVi: data['meaningVi'] as String,
      modelId: data['modelId'] as String,
      needsReview: data['needsReview'] as bool? ?? false,
      savedAt: (data['savedAt'] as Timestamp).toDate(),
      repetitions: data['repetitions'] as int? ?? 0,
      easeFactor: (data['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: data['intervalDays'] as int? ?? 0,
      nextReviewAt: (data['nextReviewAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncedAt: DateTime.now(), // vừa pull về = vừa sync xong
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'kanji': kanji,
        'romaji': romaji,
        'meaningVi': meaningVi,
        'modelId': modelId,
        'needsReview': needsReview,
        'savedAt': Timestamp.fromDate(savedAt),
        'repetitions': repetitions,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'nextReviewAt': Timestamp.fromDate(nextReviewAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  VocabWord copyWith({
    bool? needsReview,
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
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
        updatedAt: updatedAt ?? this.updatedAt,
        syncedAt: syncedAt ?? this.syncedAt,
      );
}