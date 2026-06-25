import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import '../../services/origami_service.dart';
import 'assembly_screen.dart';

class FoldModuleScreen extends StatefulWidget {
  final OrigamiModel model;
  final Color paperColor;

  const FoldModuleScreen({
    super.key,
    required this.model,
    required this.paperColor,
  });

  @override
  State<FoldModuleScreen> createState() => _FoldModuleScreenState();
}

class _FoldModuleScreenState extends State<FoldModuleScreen> {
  final _service = OrigamiService();
  late Future<ModuleData> _dataFuture;

  int _currentModule = 0;
  int _currentStep = 0;
  final Set<String> _savedVocabs = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = _service.getModuleData(widget.model.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ModuleData>(
      future: _dataFuture,
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

        final data = snapshot.data!;
        final module = data.modules[_currentModule];
        final step = module.steps[_currentStep];
        final isLastStep = _currentStep == module.steps.length - 1;
        final isLastModule = _currentModule == data.modules.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.model.nameVi),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Module ${_currentModule + 1}/${data.modules.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Progress bar kép: module + step ──
              _buildDoubleProgressBar(data, module),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Module header ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text('🧩', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.moduleTitle,
                                  style: const TextStyle(
                                    color: AppTheme.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  module.moduleTitleJP,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'Bước ${_currentStep + 1}/${module.steps.length}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
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
                            color: widget.paperColor.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.extension_outlined,
                                size: 64,
                                color: widget.paperColor.withOpacity(0.6)),
                            const SizedBox(height: 8),
                            Text(
                              'Module ${module.moduleIndex} · Bước ${step.stepIndex}',
                              style: TextStyle(
                                  color: widget.paperColor.withOpacity(0.8),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Hướng dẫn + từ JP ──
                      const Text(
                        'HƯỚNG DẪN',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionText(step),
                      const SizedBox(height: 20),

                      // ── Vocab cards ──
                      if (step.vocabList.isNotEmpty) ...[
                        const Text(
                          'TỪ VỰNG',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        ...step.vocabList.map((v) => _VocabCard(
                              vocab: v,
                              isSaved: _savedVocabs.contains(v.kanji),
                              onSave: () => _toggleSave(v.kanji, context),
                            )),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Nút điều hướng ──
              _buildNavButtons(
                  isLastStep: isLastStep,
                  isLastModule: isLastModule,
                  data: data,
                  module: module),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoubleProgressBar(ModuleData data, ModuleGroup module) {
    return Column(
      children: [
        // Module progress
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Row(
            children: [
              const Text('Module  ',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentModule + 1) / data.modules.length,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation(AppTheme.amber),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        // Step progress trong module
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: Row(
            children: [
              const Text('Bước    ',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / module.steps.length,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation(AppTheme.teal),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButtons({
    required bool isLastStep,
    required bool isLastModule,
    required ModuleData data,
    required ModuleGroup module,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0 || _currentModule > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    if (_currentStep > 0) {
                      _currentStep--;
                    } else {
                      _currentModule--;
                      _currentStep =
                          data.modules[_currentModule].steps.length - 1;
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('← Trước',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          if (_currentStep > 0 || _currentModule > 0)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (!isLastStep) {
                  // Sang bước tiếp trong module
                  setState(() => _currentStep++);
                } else if (!isLastModule) {
                  // Hết module → popup chuyển module tiếp
                  _showNextModuleDialog(data);
                } else {
                  // Hết module cuối → sang Assembly
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => AssemblyScreen(
                        model: widget.model,
                        paperColor: widget.paperColor,
                        assemblySteps: data.assembly,
                        savedVocabs: _savedVocabs,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isLastStep && isLastModule
                    ? '🔧 Lắp ráp!'
                    : isLastStep
                        ? 'Module tiếp →'
                        : 'Tiếp theo →',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNextModuleDialog(ModuleData data) {
    final nextModule = data.modules[_currentModule + 1];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Xong module này!',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Tiếp theo: ${nextModule.moduleTitle} (${nextModule.moduleTitleJP})',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ở lại', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentModule++;
                _currentStep = 0;
              });
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  void _toggleSave(String kanji, BuildContext context) {
    setState(() {
      if (_savedVocabs.contains(kanji)) {
        _savedVocabs.remove(kanji);
      } else {
        _savedVocabs.add(kanji);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_savedVocabs.contains(kanji)
          ? '⭐ Đã lưu "$kanji"'
          : '✖ Đã bỏ lưu "$kanji"'),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black87,
    ));
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
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
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
              color: AppTheme.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: const Border(
                  bottom: BorderSide(color: AppTheme.amber, width: 1.5)),
            ),
            child: Text(kanji,
                style: const TextStyle(
                    color: AppTheme.amber,
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
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  void _showTooltip(String kanji, String romaji, String meaning) {
    final isSaved = _savedVocabs.contains(kanji);
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
                style: const TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            Text(meaning,
                style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _toggleSave(kanji, context);
                  Navigator.pop(context);
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

// ── VocabCard (dùng chung với fold_step_screen) ───────────────────────────────
class _VocabCard extends StatelessWidget {
  final VocabRef vocab;
  final bool isSaved;
  final VoidCallback onSave;
  const _VocabCard(
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
            color: isSaved
                ? AppTheme.amber.withOpacity(0.4)
                : Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vocab.kanji,
                    style: const TextStyle(
                        color: AppTheme.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(vocab.romaji,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(vocab.meaningVi,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
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