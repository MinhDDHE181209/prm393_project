import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import '../../providers/fold_session_provider.dart';
import '../../services/origami_service.dart';
import '../../widgets/vocab_card.dart';

class FoldModuleScreen extends ConsumerStatefulWidget {
  final OrigamiModel model;

  const FoldModuleScreen({
    super.key,
    required this.model,
  });

  @override
  ConsumerState<FoldModuleScreen> createState() => _FoldModuleScreenState();
}

class _FoldModuleScreenState extends ConsumerState<FoldModuleScreen> {
  final _service = OrigamiService();
  late Future<ModuleData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _service.getModuleData(widget.model.id);
    Future.microtask(() => ref
        .read(foldSessionProvider.notifier)
        .initSession(widget.model.id, FoldFlowType.module));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(foldSessionProvider);
    if (!session.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
      );
    }

    final _currentModule = session.currentModule;
    final _currentStep = session.currentStep;
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
              _buildDoubleProgressBar(
                  data, module, _currentModule, _currentStep),

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
                            color: AppTheme.amber.withOpacity(0.4),
                            width: 2,
                          ),
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
                                      Icon(Icons.extension_outlined,
                                          size: 64,
                                          color: AppTheme.amber.withOpacity(0.6)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Module ${module.moduleIndex} · Bước ${step.stepIndex}',
                                        style: TextStyle(
                                            color: AppTheme.amber.withOpacity(0.8),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  Icon(Icons.extension_outlined,
                                      size: 64,
                                      color: AppTheme.amber.withOpacity(0.6)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Module ${module.moduleIndex} · Bước ${step.stepIndex}',
                                    style: TextStyle(
                                        color: AppTheme.amber.withOpacity(0.8),
                                        fontSize: 14),
                                    ),
                                  ],
                                ),
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
                      ...step.vocabList.map((v) => VocabCard(vocab: v)),
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
                  module: module,
                  currentModule: _currentModule,
                  currentStep: _currentStep),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoubleProgressBar(
    ModuleData data,
    ModuleGroup module,
    int currentModule,
    int currentStep,
  ) {
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
                  value: (currentModule + 1) / data.modules.length,
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
                  value: (currentStep + 1) / module.steps.length,
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
    required int currentModule,
    required int currentStep,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          if (currentStep > 0 || currentModule > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  if (currentStep > 0) {
                    ref
                        .read(foldSessionProvider.notifier)
                        .setModuleStep(currentModule, currentStep - 1);
                  } else {
                    final prevModule = currentModule - 1;
                    ref.read(foldSessionProvider.notifier).setModuleStep(
                          prevModule,
                          data.modules[prevModule].steps.length - 1,
                        );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('← Trước',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          if (currentStep > 0 || currentModule > 0)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                if (!isLastStep) {
                  await ref.read(foldSessionProvider.notifier).advanceStep();
                } else if (!isLastModule) {
                  _showNextModuleDialog(data, currentModule);
                } else {
                  context.pushReplacementNamed(
                    AppRoutes.assembly,
                    pathParameters: {'modelId': widget.model.id},
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

  void _showNextModuleDialog(ModuleData data, int currentModule) {
    final nextModule = data.modules[currentModule + 1];
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
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(foldSessionProvider.notifier)
                  .advanceModule(currentModule + 1);
            },
            child: const Text('Tiếp tục'),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}