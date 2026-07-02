import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary.dart';
import '../models/collection_model.dart';
import '../models/origami_model.dart';
import '../services/vocab_service.dart';
import 'auth_provider.dart';
import 'collection_provider.dart';

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

// ─── Lớp chứa thông tin từ vựng đã được nhóm theo Collection ──────────────────
class CollectionGroupedVocabs {
  final CollectionModel collection;
  final List<VocabWord> words;
  const CollectionGroupedVocabs({required this.collection, required this.words});
}

// ─── Grouped Vocabs Provider ──────────────────────────────────────────────────
final groupedVocabsProvider = FutureProvider.autoDispose<List<CollectionGroupedVocabs>>((ref) async {
  final service = ref.read(origamiServiceProvider);
  
  // 1. Tải tất cả collections
  final collections = await service.getCollections();
  
  // 2. Tải tất cả models để map modelId -> Collection
  final allModels = <OrigamiModel>[];
  for (final c in collections) {
    try {
      final models = await service.getModelsInCollection(c.id);
      allModels.addAll(models);
    } catch (_) {}
  }
  
  final modelToCollectionMap = <String, CollectionModel>{};
  for (final m in allModels) {
    final col = collections.firstWhere((c) => c.id == m.collectionId, orElse: () => collections.first);
    modelToCollectionMap[m.id] = col;
  }
  
  // 3. Lấy từ vựng hiện tại sau khi filter (nếu null thì coi như danh sách trống)
  final wordsAsync = ref.watch(filteredVocabProvider);
  final words = wordsAsync.valueOrNull ?? [];
  
  // 4. Nhóm từ vựng theo collectionId
  final groupsMap = <String, List<VocabWord>>{};
  for (final w in words) {
    final col = modelToCollectionMap[w.modelId];
    final colId = col?.id ?? 'other';
    groupsMap.putIfAbsent(colId, () => []).add(w);
  }
  
  // 5. Chuyển đổi map thành List<CollectionGroupedVocabs>
  final result = <CollectionGroupedVocabs>[];
  for (final entry in groupsMap.entries) {
    if (entry.key == 'other') {
      const dummyCollection = CollectionModel(
        id: 'other',
        title: 'Từ vựng khác',
        titleJP: 'その他',
        coverUrl: '',
        emoji: '📚',
        price: 0,
        isUnlocked: true,
      );
      result.add(CollectionGroupedVocabs(collection: dummyCollection, words: entry.value));
    } else {
      final col = collections.firstWhere((c) => c.id == entry.key);
      result.add(CollectionGroupedVocabs(collection: col, words: entry.value));
    }
  }
  
  return result;
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
