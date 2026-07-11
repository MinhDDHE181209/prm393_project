import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/progress_service.dart';
import '../services/vocab_service.dart';
import '../models/origami_model.dart';
import 'auth_provider.dart';
import 'collection_provider.dart';
import 'progress_provider.dart';
import 'vocab_provider.dart';

enum FoldFlowType { step, module }

class FoldSessionState {
  final String? modelId;
  final FoldFlowType? flowType;
  final int currentStep;
  final int currentModule;
  final Set<String> savedVocabs;
  final bool isLoaded;

  const FoldSessionState({
    this.modelId,
    this.flowType,
    this.currentStep = 0,
    this.currentModule = 0,
    this.savedVocabs = const {},
    this.isLoaded = false,
  });

  int get encodedPosition => currentModule * 1000 + currentStep;

  FoldSessionState copyWith({
    String? modelId,
    FoldFlowType? flowType,
    int? currentStep,
    int? currentModule,
    Set<String>? savedVocabs,
    bool? isLoaded,
  }) =>
      FoldSessionState(
        modelId: modelId ?? this.modelId,
        flowType: flowType ?? this.flowType,
        currentStep: currentStep ?? this.currentStep,
        currentModule: currentModule ?? this.currentModule,
        savedVocabs: savedVocabs ?? this.savedVocabs,
        isLoaded: isLoaded ?? this.isLoaded,
      );
}

class FoldSessionNotifier extends Notifier<FoldSessionState> {
  ProgressService get _progress => ref.read(progressServiceProvider);
  VocabService get _vocab => ref.read(vocabServiceProvider);

  String? get _uid {
    final uid = ref.read(currentUidProvider);
    return uid == 'guest' ? null : uid;
  }

  @override
  FoldSessionState build() => const FoldSessionState();

  Future<void> initSession(String modelId, FoldFlowType type) async {
    final uid = _uid;
    var step = 0;
    var module = 0;
    final vocabs = <String>{};

    if (uid != null) {
      final session = await _progress.getLastSession(uid);
      if (session != null && session['model_id'] == modelId) {
        final encoded = session['current_step'] as int;
        if (type == FoldFlowType.module) {
          module = encoded ~/ 1000;
          step = encoded % 1000;
        } else {
          step = encoded;
        }
      }
      final words = await _vocab.getWords(uid);
      vocabs.addAll(words.map((w) => w.kanji));
    }

    state = FoldSessionState(
      modelId: modelId,
      flowType: type,
      currentStep: step,
      currentModule: module,
      savedVocabs: vocabs,
      isLoaded: true,
    );
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setModuleStep(int module, int step) {
    state = state.copyWith(currentModule: module, currentStep: step);
  }

  Future<void> advanceStep() async {
    state = state.copyWith(currentStep: state.currentStep + 1);
    await saveSession();
  }

  Future<void> advanceModule(int nextModule) async {
    state = state.copyWith(currentModule: nextModule, currentStep: 0);
    await saveSession();
  }

  Future<void> saveSession() async {
    final uid = _uid;
    if (uid == null || state.modelId == null) return;

    final encoded = state.flowType == FoldFlowType.module
        ? state.encodedPosition
        : state.currentStep;

    await _progress.saveSession(
      userId: uid,
      modelId: state.modelId!,
      currentStep: encoded,
    );
  }

  Future<void> clearSession() async {
    final uid = _uid;
    if (uid == null || state.modelId == null) return;
    await _progress.clearSession(userId: uid, modelId: state.modelId!);
    state = const FoldSessionState();
  }

  Future<bool> toggleVocab({
    required String kanji,
    required String romaji,
    required String meaningVi,
    required String modelId,
  }) async {
    final uid = _uid;
    final wasSaved = state.savedVocabs.contains(kanji);
    final next = Set<String>.from(state.savedVocabs);
    if (wasSaved) {
      next.remove(kanji);
    } else {
      next.add(kanji);
    }
    state = state.copyWith(savedVocabs: next);

    if (uid != null) {
      if (wasSaved) {
        await _vocab.removeWord(userId: uid, kanji: kanji);
      } else {
        await _vocab.saveWord(
          userId: uid,
          kanji: kanji,
          romaji: romaji,
          meaningVi: meaningVi,
          modelId: modelId,
        );
      }
      ref.invalidate(vocabListProvider);
    }
    return !wasSaved;
  }

  List<String> get savedVocabsList => state.savedVocabs.toList();
}

final foldSessionProvider =
    NotifierProvider<FoldSessionNotifier, FoldSessionState>(
        FoldSessionNotifier.new);

class InProgressData {
  final OrigamiModel model;
  final String emoji;
  final double percent;
  
  const InProgressData({
    required this.model,
    required this.emoji,
    required this.percent,
  });
}

/// Session đang dở (dùng cho thẻ "Tiếp tục gấp" ở Home).
final inProgressSessionProvider =
    FutureProvider.autoDispose<InProgressData?>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == 'guest') return null;
  final session = await ref.read(progressServiceProvider).getLastSession(uid);
  if (session == null) return null;

  try {
      final modelId = session['model_id'] as String;
      final encoded = session['current_step'] as int;
      final service = ref.read(origamiServiceProvider);
      final model   = await service.getModelById(modelId);

      // encoded = modulePart * 1000 + stepPart
      // stepPart là bước hiện tại (0-based index đã +1 khi lưu)
      final stepPart  = encoded % 1000;           // bước trong module
      final total     = model.stepCount > 0 ? model.stepCount : 10;
      final percent   = (stepPart / total).clamp(0.0, 1.0);

      // Chọn emoji dựa trên tên model
      String pickEmoji(String name) {
        final n = name.toLowerCase();
        if (n.contains('hạc') || n.contains('crane')) return '🦢';
        if (n.contains('bướm') || n.contains('butterfly')) return '🦋';
        if (n.contains('cá') || n.contains('fish')) return '🐟';
        if (n.contains('hoa') || n.contains('flower')) return '🌸';
        if (n.contains('thỏ') || n.contains('rabbit')) return '🐰';
        if (n.contains('khủng long') || n.contains('dino')) return '🦕';
        return '🎏';
      }

      return InProgressData(
        model:   model,
        emoji:   pickEmoji(model.nameVi),
        percent: percent,
      );
  } catch (_) {
      return null;
  }
});
