import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import '../../providers/fold_session_provider.dart';
import '../../services/origami_service.dart';

class AssemblyScreen extends ConsumerStatefulWidget {
  final OrigamiModel model;
  final Color paperColor;

  const AssemblyScreen({
    super.key,
    required this.model,
    required this.paperColor,
  });

  @override
  ConsumerState<AssemblyScreen> createState() => _AssemblyScreenState();
}

class _AssemblyScreenState extends ConsumerState<AssemblyScreen> {
  int _currentStep = 0;
  late Future<List<FoldStep>> _assemblyFuture;

  @override
  void initState() {
    super.initState();
    _assemblyFuture = OrigamiService()
        .getModuleData(widget.model.id)
        .then((data) => data.assembly);
  }

  @override
  Widget build(BuildContext context) {
    final savedVocabs = ref.watch(foldSessionProvider).savedVocabs;

    return FutureBuilder<List<FoldStep>>(
      future: _assemblyFuture,
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
                      const Text('HƯỚNG DẪN LẮP RÁP',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      _buildInstructionText(step),
                      const SizedBox(height: 20),
                      if (step.vocabList.isNotEmpty) ...[
                        const Text('TỪ VỰNG',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        ...step.vocabList.map((v) => _AssemblyVocabCard(
                              vocab: v,
                              isSaved: savedVocabs.contains(v.kanji),
                              onSave: () => _toggleVocab(v),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
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
                            context.pushReplacementNamed(
                              AppRoutes.complete,
                              pathParameters: {'modelId': widget.model.id},
                              queryParameters: {
                                AppRoutes.paperColorQuery:
                                    AppRouter.paperColorQuery(widget.paperColor),
                              },
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
      },
    );
  }

  Future<void> _toggleVocab(VocabRef vocab) async {
    final saved = await ref.read(foldSessionProvider.notifier).toggleVocab(
          kanji: vocab.kanji,
          romaji: vocab.romaji,
          meaningVi: vocab.meaningVi,
          modelId: widget.model.id,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(saved
          ? '⭐ Đã lưu "${vocab.kanji}"'
          : '✖ Đã bỏ lưu "${vocab.kanji}"'),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black87,
    ));
  }

  Widget _buildInstructionText(FoldStep step) {
    return Text(
      step.instructionVi.replaceAll(RegExp(r'\[\[(.+?)\|(.+?)\|(.+?)\]\]'), r'$1'),
      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
    );
  }
}

class _AssemblyVocabCard extends StatelessWidget {
  final VocabRef vocab;
  final bool isSaved;
  final VoidCallback onSave;

  const _AssemblyVocabCard({
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
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(vocab.meaningVi,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
