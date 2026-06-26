import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import '../../services/origami_service.dart';
import 'complete_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/progress_service.dart';

class FoldStepScreen extends StatefulWidget {
  final OrigamiModel model;
  final Color paperColor;

  const FoldStepScreen({
    super.key,
    required this.model,
    required this.paperColor,
  });

  @override
  State<FoldStepScreen> createState() => _FoldStepScreenState();
}

class _FoldStepScreenState extends State<FoldStepScreen> {
  final _service = OrigamiService();
  late Future<List<FoldStep>> _stepsFuture;
  int _currentStep = 0;
  final Set<String> _savedVocabs = {}; // kanji đã lưu trong session này

  @override
  void initState() {
    super.initState();
    _stepsFuture = _service.getFoldSteps(widget.model.id);
    
    
  }
  Future<void> _loadSession() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final progressService = ProgressService();
  final session = await progressService.getLastSession(userId);
  if (session != null && session['modelId'] == widget.model.id) {
    setState(() => _currentStep = session['currentStep'] as int);
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoldStep>>(
      future: _stepsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: Center(child: Text('${snapshot.error}')),
          );
        }

        final steps = snapshot.data!;
        final step = steps[_currentStep];
        final isLast = _currentStep == steps.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.model.nameVi),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Bước ${_currentStep + 1}/${steps.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Progress bar ──
              LinearProgressIndicator(
                value: (_currentStep + 1) / steps.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppTheme.amber),
                minHeight: 4,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Ảnh minh hoạ bước gấp ──
                      Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.paperColor.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Placeholder ảnh — sau này thay bằng Image.asset hoặc GIF
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.style_outlined,
                                  size: 64,
                                  color: widget.paperColor.withOpacity(0.6),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bước ${step.stepIndex}',
                                  style: TextStyle(
                                    color: widget.paperColor.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Hướng dẫn có từ JP ──
                      const Text(
                        'Hướng dẫn',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionText(step),
                      const SizedBox(height: 20),

                      // ── Từ vựng JP trong bước này ──
                      if (step.vocabList.isNotEmpty) ...[
                        const Text(
                          'Từ vựng trong bước này',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...step.vocabList.map((v) => _VocabCard(
                          vocab: v,
                          isSaved: _savedVocabs.contains(v.kanji),
                          onSave: () {
                            setState(() {
                              if (_savedVocabs.contains(v.kanji)) {
                                _savedVocabs.remove(v.kanji);
                              } else {
                                _savedVocabs.add(v.kanji);
                              }
                            });
                            // TODO: Phase 5 — gọi VocabService.saveWord()
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _savedVocabs.contains(v.kanji)
                                      ? '⭐ Đã lưu "${v.kanji}" vào Word Vault'
                                      : '✖ Đã bỏ lưu "${v.kanji}"',
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.black87,
                              ),
                            );
                          },
                        )),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Nút điều hướng ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    top: BorderSide(color: Colors.white12),
                  ),
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: const Text(
                            '← Trước',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                       onPressed: () {
  if (isLast) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CompleteScreen(
          model: widget.model,
          paperColor: widget.paperColor,
          savedVocabs: _savedVocabs.toList(),
        ),
      ),
    );
  } else {
onPressed: () {
  setState(() => _currentStep++);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    ProgressService().saveSession(
      userId: userId,
      modelId: widget.model.id,
      currentStep: _currentStep,
    );
  }
};  }
},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isLast ? '🎉 Hoàn thành!' : 'Tiếp theo →',
                          
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Parse chuỗi instructionVi có dạng [[kanji|romaji|nghĩa]]
  /// thành các TextSpan — từ JP hiện màu Amber và có thể tap.
  Widget _buildInstructionText(FoldStep step) {
    final text = step.instructionVi;
    final regex = RegExp(r'\[\[(.+?)\|(.+?)\|(.+?)\]\]');
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Phần text thường trước từ JP
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
        ));
      }
      final kanji = match.group(1)!;
      final romaji = match.group(2)!;
      final meaning = match.group(3)!;

      // Từ JP — gạch chân màu Amber, tap để xem tooltip
      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => _showVocabTooltip(kanji, romaji, meaning, step),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border(
                bottom: BorderSide(color: AppTheme.amber, width: 1.5),
              ),
            ),
            child: Text(
              kanji,
              style: const TextStyle(
                color: AppTheme.amber,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ));
      lastEnd = match.end;
    }

    // Phần text thường còn lại
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  void _showVocabTooltip(
    String kanji,
    String romaji,
    String meaning,
    FoldStep step,
  ) {
    final isSaved = _savedVocabs.contains(kanji);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kanji,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              romaji,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              meaning,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (isSaved) {
                      _savedVocabs.remove(kanji);
                    } else {
                      _savedVocabs.add(kanji);
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved
                            ? '✖ Đã bỏ lưu "$kanji"'
                            : '⭐ Đã lưu "$kanji" vào Word Vault',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
                icon: Icon(isSaved ? Icons.star : Icons.star_border),
                label: Text(isSaved ? 'Bỏ lưu từ này' : '⭐ Lưu vào Word Vault'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Vocab Card hiển thị dưới hướng dẫn ───────────────────────────────────────
class _VocabCard extends StatelessWidget {
  final VocabRef vocab;
  final bool isSaved;
  final VoidCallback onSave;

  const _VocabCard({
    required this.vocab,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSaved ? AppTheme.amber.withOpacity(0.4) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab.kanji,
                  style: const TextStyle(
                    color: AppTheme.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  vocab.romaji,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  vocab.meaningVi,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSave,
            icon: Icon(
              isSaved ? Icons.star : Icons.star_border,
              color: isSaved ? AppTheme.amber : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}