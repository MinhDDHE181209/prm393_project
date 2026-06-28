import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/theme.dart';
import '../models/fold_step.dart';
import '../models/origami_model.dart';
import '../services/origami_service.dart';
import '../services/progress_service.dart';
import '../services/vocab_service.dart';
import 'complete_screen.dart';
import '../app/constants.dart';
class FoldStepScreen extends StatefulWidget {
  final OrigamiModel model;
  final Color        paperColor;

  const FoldStepScreen({super.key, required this.model, required this.paperColor});

  @override
  State<FoldStepScreen> createState() => _FoldStepScreenState();
}

class _FoldStepScreenState extends State<FoldStepScreen> {
  final _origamiService   = OrigamiService();
  final _progressService  = ProgressService();
  final _vocabService     = VocabService();

  late Future<List<FoldStep>> _stepsFuture;
  int            _currentStep = 0;
  final Set<String> _savedVocabs = {}; // kanji đã lưu trong session

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _stepsFuture = _origamiService.getFoldSteps(widget.model.id);
    _loadSession();
    _loadSavedVocabs();
  }

  Future<void> _loadSession() async {
    final uid = _uid;
    if (uid == null) return;
    final session = await _progressService.getLastSession(uid);
    if (session != null && session['modelId'] == widget.model.id && mounted) {
      setState(() => _currentStep = session['currentStep'] as int);
    }
  }

  Future<void> _loadSavedVocabs() async {
    final uid = _uid;
    if (uid == null) return;
    final words = await _vocabService.getWords(uid);
    if (mounted) setState(() => _savedVocabs.addAll(words.map((w) => w.kanji)));
  }

  Future<void> _toggleVocab(VocabRef vocab) async {
    final uid    = _uid;
    final isSaved = _savedVocabs.contains(vocab.kanji);

    setState(() {
      if (isSaved) {
        _savedVocabs.remove(vocab.kanji);
      } else {
        _savedVocabs.add(vocab.kanji);
      }
    });

    if (uid != null) {
      if (isSaved) {
        await _vocabService.removeWord(userId: uid, kanji: vocab.kanji);
      } else {
        await _vocabService.saveWord(
          userId:    uid,
          kanji:     vocab.kanji,
          romaji:    vocab.romaji,
          meaningVi: vocab.meaningVi,
          modelId:   widget.model.id,
        );
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isSaved
          ? '✖ Đã bỏ lưu "${vocab.kanji}"'
          : '⭐ Đã lưu "${vocab.kanji}" vào Word Vault'),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black87,
    ));
  }

  Future<void> _goNext() async {
    final uid  = _uid;
    final next = _currentStep + 1;
    setState(() => _currentStep = next);
    if (uid != null) {
      await _progressService.addXP(uid, AppConstants.xpPerStep);
      await _progressService.saveSession(
          userId: uid, modelId: widget.model.id, currentStep: next);
    }
  }

  Future<void> _finish() async {
    final uid = _uid;
    if (uid != null) {
      // ✅ FIX: đủ 4 calls, đúng signature
      await _progressService.addXP(uid, AppConstants.xpPerCompleteModel);
      await _progressService.incrementModelsCompleted(uid);
      await _progressService.updateStreak(uid);
      await _progressService.clearSession(userId: uid, modelId: widget.model.id);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => CompleteScreen(
        model:       widget.model,
        paperColor:  widget.paperColor,
        savedVocabs: _savedVocabs.toList(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoldStep>>(
      future: _stepsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppTheme.amber)));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
              appBar: AppBar(title: const Text('Lỗi')),
              body: Center(child: Text('${snapshot.error}')));
        }

        final steps  = snapshot.data!;
        final step   = steps[_currentStep];
        final isLast = _currentStep == steps.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.model.nameVi),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text('Bước ${_currentStep + 1}/${steps.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),
            ],
          ),
          body: Column(children: [
            LinearProgressIndicator(
              value:      (_currentStep + 1) / steps.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppTheme.amber),
              minHeight:  4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Ảnh bước gấp ──
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: widget.paperColor.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.style_outlined,
                              size: 64,
                              color: widget.paperColor.withValues(alpha: 0.6)),
                          const SizedBox(height: 8),
                          Text('Bước ${step.stepIndex}',
                              style: TextStyle(
                                  color: widget.paperColor.withValues(alpha: 0.8),
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Hướng dẫn ──
                    const Text('HƯỚNG DẪN',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    _buildInstructionText(step),
                    const SizedBox(height: 20),

                    // ── Vocab cards ──
                    if (step.vocabList.isNotEmpty) ...[
                      const Text('TỪ VỰNG TRONG BƯỚC NÀY',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      ...step.vocabList.map((v) => _VocabCard(
                            vocab:   v,
                            isSaved: _savedVocabs.contains(v.kanji),
                            onToggle: () => _toggleVocab(v),
                          )),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Navigation bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: Colors.white12))),
              child: Row(children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.white24)),
                      child: const Text('← Trước',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLast ? _finish : _goNext,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(isLast ? '🎉 Hoàn thành!' : 'Tiếp theo →',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildInstructionText(FoldStep step) {
    final text  = step.instructionVi;
    final regex = RegExp(r'\[\[(.+?)\|(.+?)\|(.+?)\]\]');
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
            text: text.substring(lastEnd, match.start),
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)));
      }
      final kanji   = match.group(1)!;
      final romaji  = match.group(2)!;
      final meaning = match.group(3)!;

      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => _showVocabTooltip(VocabRef(
              kanji: kanji, romaji: romaji, meaningVi: meaning)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: const Border(bottom: BorderSide(color: AppTheme.amber, width: 1.5)),
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
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)));
    }

    return RichText(text: TextSpan(children: spans));
  }

  void _showVocabTooltip(VocabRef vocab) {
    final isSaved = _savedVocabs.contains(vocab.kanji);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(vocab.kanji,
              style: const TextStyle(
                  color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(vocab.romaji,
              style: const TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 8),
          Text(vocab.meaningVi,
              style: const TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _toggleVocab(vocab);
              },
              icon: Icon(isSaved ? Icons.star : Icons.star_border),
              label: Text(isSaved ? 'Bỏ lưu từ này' : '⭐ Lưu vào Word Vault'),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Vocab Card ────────────────────────────────────────────────────────────────
class _VocabCard extends StatelessWidget {
  final VocabRef     vocab;
  final bool         isSaved;
  final VoidCallback onToggle;

  const _VocabCard({required this.vocab, required this.isSaved, required this.onToggle});

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
                ? AppTheme.amber.withValues(alpha: 0.4)
                : Colors.white12),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vocab.kanji,
                style: const TextStyle(
                    color: AppTheme.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(vocab.romaji,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(vocab.meaningVi,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        IconButton(
          onPressed: onToggle,
          icon: Icon(
            isSaved ? Icons.star : Icons.star_border,
            color: isSaved ? AppTheme.amber : Colors.white38,
          ),
        ),
      ]),
    );
  }
}