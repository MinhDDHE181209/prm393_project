import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import '../app/theme.dart';
import '../models/fold_step.dart';
import '../models/origami_model.dart';
import '../providers/fold_session_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/auth_provider.dart';
import '../services/origami_service.dart';
import '../widgets/vocab_card.dart';

class FoldStepScreen extends ConsumerStatefulWidget {
  final OrigamiModel model;

  const FoldStepScreen({super.key, required this.model});

  @override
  ConsumerState<FoldStepScreen> createState() => _FoldStepScreenState();
}

class _FoldStepScreenState extends ConsumerState<FoldStepScreen> {
  late Future<List<FoldStep>> _stepsFuture;

  @override
  void initState() {
    super.initState();
    _stepsFuture = OrigamiService().getFoldSteps(widget.model.id);
    Future.microtask(() => ref
        .read(foldSessionProvider.notifier)
        .initSession(widget.model.id, FoldFlowType.step));
  }

  Future<void> _goNext() async {
    final uid = ref.read(currentUidProvider);
    if (uid != 'guest') {
      await ref.read(progressNotifierProvider.notifier).addXP(AppConstants.xpPerStep);
    }
    await ref.read(foldSessionProvider.notifier).advanceStep();
  }

  Future<void> _finish() async {
    if (!mounted) return;
    context.pushReplacementNamed(
      AppRoutes.complete,
      pathParameters: {'modelId': widget.model.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(foldSessionProvider);

    if (!session.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
      );
    }

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

        final steps = snapshot.data!;
        final currentStep = session.currentStep.clamp(0, steps.length - 1);
        final step = steps[currentStep];
        final isLast = currentStep == steps.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.model.nameVi),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text('Bước ${currentStep + 1}/${steps.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),
            ],
          ),
          body: Column(children: [
            LinearProgressIndicator(
              value: (currentStep + 1) / steps.length,
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
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.amber.withValues(alpha: 0.4), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: step.imageUrl.isNotEmpty
                            ? Image.asset(
                                step.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.style_outlined,
                                        size: 64,
                                        color: AppTheme.amber.withValues(alpha: 0.6)),
                                    const SizedBox(height: 8),
                                    Text('Bước ${step.stepIndex}',
                                        style: TextStyle(
                                            color: AppTheme.amber.withValues(alpha: 0.8),
                                            fontSize: 16)),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.style_outlined,
                                      size: 64,
                                      color: AppTheme.amber.withValues(alpha: 0.6)),
                                  const SizedBox(height: 8),
                                  Text('Bước ${step.stepIndex}',
                                      style: TextStyle(
                                          color: AppTheme.amber.withValues(alpha: 0.8),
                                          fontSize: 16)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('HƯỚNG DẪN',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    _buildInstructionText(step),
                    const SizedBox(height: 20),
                    if (step.vocabList.isNotEmpty) ...[
                      const Text('TỪ VỰNG TRONG BƯỚC NÀY',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      ...step.vocabList.map((v) => VocabCard(vocab: v)),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: Colors.white12))),
              child: Row(children: [
                if (currentStep > 0) ...[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(foldSessionProvider.notifier)
                          .setStep(currentStep - 1),
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
    final text = step.instructionVi;
    final regex = RegExp(r'\[\[(.+?)\|(.+?)\|(.+?)\]\]');
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
            text: text.substring(lastEnd, match.start),
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)));
      }
      final kanji = match.group(1)!;
      final romaji = match.group(2)!;
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
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
