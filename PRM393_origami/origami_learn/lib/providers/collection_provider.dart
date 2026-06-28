import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection_model.dart';
import '../models/origami_model.dart';
import '../services/origami_service.dart';
import 'auth_provider.dart';
import 'progress_provider.dart';

// ─── Service ─────────────────────────────────────────────────────────────────
final origamiServiceProvider =
    Provider<OrigamiService>((ref) => OrigamiService());

// ─── Toàn bộ collections ─────────────────────────────────────────────────────
// Merge unlock status từ UserProgress vào CollectionModel
final collectionsProvider =
    FutureProvider.autoDispose<List<CollectionModel>>((ref) async {
  final service = ref.read(origamiServiceProvider);
  final progressAsync = ref.watch(userProgressProvider);
  final collections = await service.getCollections();

  final unlockedIds =
      progressAsync.valueOrNull?.unlockedCollections ?? [];

  // Merge: collection.isUnlocked = true nếu user đã unlock
  return collections.map((c) {
    final isUnlocked = c.isUnlocked || unlockedIds.contains(c.id);
    return c.copyWith(isUnlocked: isUnlocked);
  }).toList();
});

// ─── Models trong 1 collection ───────────────────────────────────────────────
final modelsInCollectionProvider =
    FutureProvider.autoDispose.family<List<OrigamiModel>, String>(
  (ref, collectionId) async {
    final service = ref.read(origamiServiceProvider);
    return service.getModelsInCollection(collectionId);
  },
);

// ─── 1 model theo ID ─────────────────────────────────────────────────────────
final modelByIdProvider =
    FutureProvider.autoDispose.family<OrigamiModel, String>(
  (ref, modelId) async {
    final service = ref.read(origamiServiceProvider);
    return service.getModelById(modelId);
  },
);
