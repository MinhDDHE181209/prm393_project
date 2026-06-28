import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../services/vocab_service.dart';
import 'auth_provider.dart';

// ─── Enum filter ─────────────────────────────────────────────────────────────
enum VocabFilter { all, needsReview, learned }

// ─── Service ─────────────────────────────────────────────────────────────────
final vocabServiceProvider = Provider<VocabService>((ref) => VocabService());

// ─── Filter state ─────────────────────────────────────────────────────────────
final vocabFilterProvider =
    StateProvider.autoDispose<VocabFilter>((ref) => VocabFilter.all);

// ─── Danh sách từ toàn bộ ────────────────────────────────────────────────────
final vocabListProvider =
    FutureProvider.autoDispose<List<VocabWord>>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == 'guest') return [];
  final service = ref.read(vocabServiceProvider);
  return service.getWords(uid);
});

// ─── Danh sách từ sau khi filter ─────────────────────────────────────────────
final filteredVocabProvider =
    Provider.autoDispose<AsyncValue<List<VocabWord>>>((ref) {
  final allAsync = ref.watch(vocabListProvider);
  final filter = ref.watch(vocabFilterProvider);

  return allAsync.whenData((all) {
    switch (filter) {
      case VocabFilter.all:
        return all;
      case VocabFilter.needsReview:
        return all.where((w) => w.needsReview).toList();
      case VocabFilter.learned:
        return all.where((w) => !w.needsReview).toList();
    }
  });
});

// ─── Count badges ─────────────────────────────────────────────────────────────
final vocabCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(vocabListProvider).valueOrNull?.length ?? 0;
});

final reviewCountProvider = Provider.autoDispose<int>((ref) {
  return ref
          .watch(vocabListProvider)
          .valueOrNull
          ?.where((w) => w.needsReview)
          .length ??
      0;
});

// ─── Notifier để save/remove/markReviewed ────────────────────────────────────
class VocabNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveWord({
    required String kanji,
    required String romaji,
    required String meaningVi,
    required String modelId,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return;
    final service = ref.read(vocabServiceProvider);
    await service.saveWord(
      userId: uid,
      kanji: kanji,
      romaji: romaji,
      meaningVi: meaningVi,
      modelId: modelId,
    );
    ref.invalidate(vocabListProvider); // ✅ refresh Word Vault tức thì
  }

  Future<void> removeWord(String kanji) async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return;
    final service = ref.read(vocabServiceProvider);
    await service.removeWord(userId: uid, kanji: kanji);
    ref.invalidate(vocabListProvider);
  }

  Future<void> markReviewed(String kanji) async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return;
    final service = ref.read(vocabServiceProvider);
    await service.markReviewed(userId: uid, kanji: kanji);
    ref.invalidate(vocabListProvider);
  }

  Future<void> markNeedsReview(String kanji) async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return;
    final service = ref.read(vocabServiceProvider);
    await service.markNeedsReview(userId: uid, kanji: kanji);
    ref.invalidate(vocabListProvider);
  }
}

final vocabNotifierProvider =
    AsyncNotifierProvider<VocabNotifier, void>(VocabNotifier.new);
