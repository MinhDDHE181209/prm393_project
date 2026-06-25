class VocabRef {
  final String kanji;
  final String romaji;
  final String meaningVi;

  const VocabRef({
    required this.kanji,
    required this.romaji,
    required this.meaningVi,
  });

  factory VocabRef.fromJson(Map<String, dynamic> json) {
    return VocabRef(
      kanji: json['kanji'] as String,
      romaji: json['romaji'] as String,
      meaningVi: json['meaningVi'] as String,
    );
  }
}

class FoldStep {
  final int stepIndex;
  final String imageUrl;
  final String instructionVi; // có thể chứa từ JP dạng [[kanji|romaji|nghĩa]]
  final List<VocabRef> vocabList;

  const FoldStep({
    required this.stepIndex,
    required this.imageUrl,
    required this.instructionVi,
    required this.vocabList,
  });

  factory FoldStep.fromJson(Map<String, dynamic> json) {
    return FoldStep(
      stepIndex: json['stepIndex'] as int,
      imageUrl: json['imageUrl'] as String,
      instructionVi: json['instructionVi'] as String,
      vocabList: (json['vocabList'] as List<dynamic>? ?? [])
          .map((e) => VocabRef.fromJson(e))
          .toList(),
    );
  }
}
class ModuleGroup {
  final int moduleIndex;
  final String moduleTitle;
  final String moduleTitleJP;
  final List<FoldStep> steps;

  const ModuleGroup({
    required this.moduleIndex,
    required this.moduleTitle,
    required this.moduleTitleJP,
    required this.steps,
  });

  factory ModuleGroup.fromJson(Map<String, dynamic> json) {
    return ModuleGroup(
      moduleIndex: json['moduleIndex'] as int,
      moduleTitle: json['moduleTitle'] as String,
      moduleTitleJP: json['moduleTitleJP'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => FoldStep.fromJson(e))
          .toList(),
    );
  }
}

class ModuleData {
  final List<ModuleGroup> modules;
  final List<FoldStep> assembly;

  const ModuleData({required this.modules, required this.assembly});

  factory ModuleData.fromJson(Map<String, dynamic> json) {
    return ModuleData(
      modules: (json['modules'] as List<dynamic>)
          .map((e) => ModuleGroup.fromJson(e))
          .toList(),
      assembly: (json['assembly'] as List<dynamic>)
          .map((e) => FoldStep.fromJson(e))
          .toList(),
    );
  }
}