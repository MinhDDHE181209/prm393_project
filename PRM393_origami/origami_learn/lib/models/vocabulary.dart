class VocabWord {
  final int?     id;
  final String   userId;
  final String   kanji;
  final String   romaji;
  final String   meaningVi;
  final String   modelId;
  final bool     needsReview;
  final DateTime savedAt;

  const VocabWord({
    this.id,
    required this.userId,
    required this.kanji,
    required this.romaji,
    required this.meaningVi,
    required this.modelId,
    required this.needsReview,
    required this.savedAt,
  });

  factory VocabWord.fromMap(Map<String, dynamic> map) => VocabWord(
        id:          map['id'] as int?,
        userId:      map['user_id'] as String,
        kanji:       map['kanji'] as String,
        romaji:      map['romaji'] as String,
        meaningVi:   map['meaning_vi'] as String,
        modelId:     map['model_id'] as String,
        needsReview: (map['needs_review'] as int) == 1,
        savedAt:     DateTime.fromMillisecondsSinceEpoch(map['saved_at'] as int),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id':      userId,
        'kanji':        kanji,
        'romaji':       romaji,
        'meaning_vi':   meaningVi,
        'model_id':     modelId,
        'needs_review': needsReview ? 1 : 0,
        'saved_at':     savedAt.millisecondsSinceEpoch,
      };

  VocabWord copyWith({bool? needsReview}) => VocabWord(
        id:          id,
        userId:      userId,
        kanji:       kanji,
        romaji:      romaji,
        meaningVi:   meaningVi,
        modelId:     modelId,
        needsReview: needsReview ?? this.needsReview,
        savedAt:     savedAt,
      );
}