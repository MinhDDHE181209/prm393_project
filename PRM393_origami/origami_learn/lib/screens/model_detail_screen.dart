import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/origami_model.dart';
import 'fold_step_screen.dart';
import 'fold_module_screen.dart';

class ModelDetailScreen extends StatefulWidget {
  final OrigamiModel model;
  const ModelDetailScreen({super.key, required this.model});

  @override
  State<ModelDetailScreen> createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends State<ModelDetailScreen> {
  // Màu giấy có thể chọn
  static const List<_PaperColor> _paperColors = [
    _PaperColor(name: 'Đỏ', color: Color(0xFFE53935)),
    _PaperColor(name: 'Cam', color: Color(0xFFFB8C00)),
    _PaperColor(name: 'Vàng', color: Color(0xFFFDD835)),
    _PaperColor(name: 'Xanh lá', color: Color(0xFF43A047)),
    _PaperColor(name: 'Xanh dương', color: Color(0xFF1E88E5)),
    _PaperColor(name: 'Tím', color: Color(0xFF8E24AA)),
    _PaperColor(name: 'Hồng', color: Color(0xFFD81B60)),
    _PaperColor(name: 'Trắng', color: Color(0xFFF5F5F5)),
  ];

  int _selectedColorIndex = 0;

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
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getModelEmoji(model.difficulty),
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.nameJP,
                    style: const TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
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
            const SizedBox(height: 28),

            // ── Chọn màu giấy ──
            const Text(
              'Chọn màu giấy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_paperColors.length, (i) {
                final pc = _paperColors[i];
                final isSelected = _selectedColorIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  child: Tooltip(
                    message: pc.name,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: pc.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: pc.color.withOpacity(0.6), blurRadius: 8)]
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              'Đã chọn: ${_paperColors[_selectedColorIndex].name}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // ── Nút bắt đầu ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
             onPressed: () {
  if (model.type == 'step') {
    // 🎯 Gấp từng bước → S09 FoldStepScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoldStepScreen(
          model: model,
          paperColor: _paperColors[_selectedColorIndex].color,
        ),
      ),
    );
  } else {
  // 🧩 type == 'module'
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FoldModuleScreen(
        model: model,
        paperColor: _paperColors[_selectedColorIndex].color,
      ),
    ),
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

class _PaperColor {
  final String name;
  final Color color;
  const _PaperColor({required this.name, required this.color});
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