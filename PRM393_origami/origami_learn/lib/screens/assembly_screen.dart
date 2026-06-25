import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import 'complete_screen.dart';

class AssemblyScreen extends StatefulWidget {
  final OrigamiModel model;
  final Color paperColor;
  final List<FoldStep> assemblySteps;
  final Set<String> savedVocabs;

  const AssemblyScreen({
    super.key,
    required this.model,
    required this.paperColor,
    required this.assemblySteps,
    required this.savedVocabs,
  });

  @override
  State<AssemblyScreen> createState() => _AssemblyScreenState();
}

class _AssemblyScreenState extends State<AssemblyScreen> {
  int _currentStep = 0;
  late Set<String> _savedVocabs;

  @override
  void initState() {
    super.initState();
    _savedVocabs = Set.from(widget.savedVocabs);
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.assemblySteps;
    final step = steps[_currentStep];
    final isLast = _currentStep == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lắp ráp — ${widget.model.nameVi}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/${steps.length}',
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
            valueColor: const AlwaysStoppedAnimation(AppTheme.teal),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badge lắp ráp ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.teal.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.build_outlined,
                            color: AppTheme.teal, size: 14),
                        SizedBox(width: 6),
                        Text('Hướng dẫn lắp ráp',
                            style: TextStyle(
                                color: AppTheme.teal,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Ảnh minh hoạ ──
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.teal.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.join_full_outlined,
                            size: 64,
                            color: AppTheme.teal.withOpacity(0.6)),
                        const SizedBox(height: 8),
                        Text(
                          'Lắp ráp bước ${step.stepIndex}',
                          style: TextStyle(
                              color: AppTheme.teal.withOpacity(0.8),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Hướng dẫn ──
                  const Text('HƯỚNG DẪN LẮP RÁP',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  _buildInstructionText(step),
                  const SizedBox(height: 20),

                  // ── Vocab cards ──
                  if (step.vocabList.isNotEmpty) ...[
                    const Text('TỪ VỰNG',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    ...step.vocabList.map((v) => _AssemblyVocabCard(
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
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: Colors.white12)),
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
                      child: const Text('← Trước',
                          style: TextStyle(color: Colors.white70)),
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
                        setState(() => _currentStep++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                          isLast ? AppTheme.teal : AppTheme.amber,
                    ),
                    child: Text(
                      isLast ? '🎉 Hoàn thành!' : 'Tiếp theo →',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(FoldStep step) {
    final text = step.instructionVi;
    final regex = RegExp(r'\[\[(.+?)\|(.+?)\|(.+?)\]\]');
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style:
              const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
        ));
      }
      final kanji = match.group(1)!;
      final romaji = match.group(2)!;
      final meaning = match.group(3)!;

      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => _showTooltip(kanji, romaji, meaning),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: const Border(
                  bottom: BorderSide(color: AppTheme.teal, width: 1.5)),
            ),
            child: Text(kanji,
                style: const TextStyle(
                    color: AppTheme.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style:
            const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  void _showTooltip(String kanji, String romaji, String meaning) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(kanji,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(romaji,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            Text(meaning,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AssemblyVocabCard extends StatelessWidget {
  final VocabRef vocab;
  final bool isSaved;
  final VoidCallback onSave;
  const _AssemblyVocabCard(
      {required this.vocab, required this.isSaved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color:
                isSaved ? AppTheme.teal.withOpacity(0.4) : Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vocab.kanji,
                    style: const TextStyle(
                        color: AppTheme.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(vocab.romaji,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                Text(vocab.meaningVi,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: onSave,
            icon: Icon(
              isSaved ? Icons.star : Icons.star_border,
              color: isSaved ? AppTheme.teal : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}