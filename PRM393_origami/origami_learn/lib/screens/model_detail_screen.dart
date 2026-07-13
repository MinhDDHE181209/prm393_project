import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/origami_model.dart';

class ModelDetailScreen extends StatefulWidget {
  final OrigamiModel model;
  const ModelDetailScreen({super.key, required this.model});

  @override
  State<ModelDetailScreen> createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends State<ModelDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Scaffold(
      appBar: AppBar(
        title: Text(model.nameVi),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Preview ──
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 200,
                color: AppTheme.surface,
                child: model.thumbnailUrl.isNotEmpty
                    ? Image.asset(
                        model.thumbnailUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_getModelEmoji(model.difficulty),
                                style: const TextStyle(fontSize: 72)),
                            const SizedBox(height: 8),
                            Text(model.nameJP,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 16)),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_getModelEmoji(model.difficulty),
                              style: const TextStyle(fontSize: 72)),
                          const SizedBox(height: 8),
                          Text(model.nameJP,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 16)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Thông số ──
            Row(
              children: [
                _InfoChip(
                  icon: Icons.star,
                  label: 'Độ khó ${model.difficulty}/5',
                  color: _difficultyColor(model.difficulty),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: '${model.estimatedMinutes} phút',
                  color: Colors.white54,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.layers_outlined,
                  label: '${model.stepCount} bước',
                  color: Colors.white54,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoChip(
              icon: model.type == 'step'
                  ? Icons.format_list_numbered
                  : Icons.extension_outlined,
              label: model.type == 'step' ? '🎯 Gấp từng bước' : '🧩 Gấp module',
              color: model.type == 'step' ? AppTheme.teal : AppTheme.amber,
            ),
            const SizedBox(height: 32),

            // ── Nút bắt đầu ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (model.type == 'step') {
                    context.pushNamed(
                      AppRoutes.foldStep,
                      pathParameters: {'modelId': model.id},
                    );
                  } else {
                    context.pushNamed(
                      AppRoutes.foldModule,
                      pathParameters: {'modelId': model.id},
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Bắt đầu gấp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModelEmoji(int difficulty) {
    switch (difficulty) {
      case 1: return '🟢';
      case 2: return '🦢';
      case 3: return '🦅';
      case 4: return '🐉';
      case 5: return '⚫';
      default: return '📄';
    }
  }

  Color _difficultyColor(int difficulty) {
    switch (difficulty) {
      case 1: return Colors.green;
      case 2: return Colors.yellow;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      case 5: return Colors.grey;
      default: return Colors.white54;
    }
  }
}



class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}