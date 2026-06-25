import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/collection_model.dart';
import '../../models/origami_model.dart';
import '../../services/origami_service.dart';
import 'model_detail_screen.dart';

class CollectionDetailScreen extends StatefulWidget {
  final CollectionModel collection;
  const CollectionDetailScreen({super.key, required this.collection});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final _service = OrigamiService();
  late Future<List<OrigamiModel>> _modelsFuture;

  @override
  void initState() {
    super.initState();
    _modelsFuture = _service.getModelsInCollection(widget.collection.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.collection.emoji} ${widget.collection.title}'),
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
                collectionUnlocked: widget.collection.isUnlocked,
              );
            },
          );
        },
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final OrigamiModel model;
  final bool collectionUnlocked;

  const _ModelTile({
    required this.model,
    required this.collectionUnlocked,
  });

  bool get _isAccessible => model.isFree || collectionUnlocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isAccessible) {
          // TODO: mở S08 Mock Payment khi đến Phase 6
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔒 Mở khoá bộ sưu tập để gấp mẫu này'),
              backgroundColor: Colors.black87,
            ),
          );
          return;
        }
        Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ModelDetailScreen(model: model),
  ),
);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isAccessible ? Colors.transparent : Colors.white12,
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
                            color: _isAccessible ? Colors.white : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!_isAccessible)
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
              color: _isAccessible ? Colors.white54 : Colors.white12,
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}