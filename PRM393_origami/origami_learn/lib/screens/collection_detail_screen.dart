import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/routes.dart';
import '../app/theme.dart';
import '../models/collection_model.dart';
import '../models/origami_model.dart';
import '../services/origami_service.dart';
import '../providers/collection_provider.dart';
import '../providers/auth_provider.dart';
import 'payment_bottom_sheet.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final CollectionModel collection;
  const CollectionDetailScreen({super.key, required this.collection});

  @override
  ConsumerState<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends ConsumerState<CollectionDetailScreen> {
  final _service = OrigamiService();
  late Future<List<OrigamiModel>> _modelsFuture;

  @override
  void initState() {
    super.initState();
    _modelsFuture = _service.getModelsInCollection(widget.collection.id);
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final currentCollection = collectionsAsync.valueOrNull?.firstWhere(
          (c) => c.id == widget.collection.id,
          orElse: () => widget.collection,
        ) ??
        widget.collection;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentCollection.emoji} ${currentCollection.title}'),
      ),
      body: FutureBuilder<List<OrigamiModel>>(
        future: _modelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.amber),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          final models = snapshot.data ?? [];
          if (models.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có mẫu gấp nào.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: models.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ModelTile(
                model: models[index],
                collection: currentCollection,
                collectionUnlocked: currentCollection.isUnlocked,
              );
            },
          );
        },
      ),
    );
  }
}

class _ModelTile extends ConsumerWidget {
  final OrigamiModel model;
  final CollectionModel collection;
  final bool collectionUnlocked;

  const _ModelTile({
    required this.model,
    required this.collection,
    required this.collectionUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);
    final isAccessible = model.isFree ||
        collectionUnlocked ||
        userType.unlocksAllCollections;

    return GestureDetector(
      onTap: () {
        if (!isAccessible) {
          PaymentBottomSheet.show(context, ref, collection: collection);
          return;
        }
        context.pushNamed(
          AppRoutes.modelDetail,
          pathParameters: {'modelId': model.id},
          extra: model,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAccessible ? Colors.transparent : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            // ── Emoji độ khó ──
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _difficultyEmoji(model.difficulty),
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ── Thông tin ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          model.nameVi,
                          style: TextStyle(
                            color: isAccessible ? Colors.white : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!isAccessible)
                        const Icon(Icons.lock, color: Colors.white38, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model.nameJP,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Loại gấp
                      _Tag(
                        label: model.type == 'step' ? '🎯 Từng bước' : '🧩 Module',
                        color: model.type == 'step' ? AppTheme.teal : AppTheme.amber,
                      ),
                      const SizedBox(width: 6),
                      // Thời gian
                      _Tag(
                        label: '⏱ ${model.estimatedMinutes} phút',
                        color: Colors.white24,
                      ),
                      const SizedBox(width: 6),
                      // Số bước
                      _Tag(
                        label: '${model.stepCount} bước',
                        color: Colors.white24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ── Mũi tên ──
            Icon(
              Icons.chevron_right,
              color: isAccessible ? Colors.white54 : Colors.white12,
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyEmoji(int difficulty) {
    switch (difficulty) {
      case 1: return '🟢';
      case 2: return '🟡';
      case 3: return '🟠';
      case 4: return '🔴';
      case 5: return '⚫';
      default: return '⬜';
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}