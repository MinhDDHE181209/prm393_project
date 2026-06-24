class OrigamiModel {
  final String id;
  final String collectionId;
  final String nameVi;
  final String nameJP;
  final int difficulty; // 1–5
  final String type;   // 'step' (🎯) | 'module' (🧩)
  final bool isFree;
  final String thumbnailUrl;
  final int estimatedMinutes;
  final int stepCount;

  const OrigamiModel({
    required this.id,
    required this.collectionId,
    required this.nameVi,
    required this.nameJP,
    required this.difficulty,
    required this.type,
    required this.isFree,
    required this.thumbnailUrl,
    required this.estimatedMinutes,
    required this.stepCount,
  });

  factory OrigamiModel.fromJson(Map<String, dynamic> json) {
    return OrigamiModel(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      nameVi: json['nameVi'] as String,
      nameJP: json['nameJP'] as String,
      difficulty: json['difficulty'] as int,
      type: json['type'] as String,
      isFree: json['isFree'] as bool,
      thumbnailUrl: json['thumbnailUrl'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      stepCount: json['stepCount'] as int,
    );
  }
}