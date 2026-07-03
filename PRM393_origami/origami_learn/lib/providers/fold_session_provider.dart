import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/progress_service.dart';
import '../services/vocab_service.dart';
import 'auth_provider.dart';
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

/// Session đang dở (dùng cho thẻ "Tiếp tục gấp" ở Home).
final inProgressSessionProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == 'guest') return null;
  return ref.read(progressServiceProvider).getLastSession(uid);
});
