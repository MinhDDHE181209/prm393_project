import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/fold_step.dart';
import '../../models/origami_model.dart';
import '../../services/origami_service.dart';
import '../../widgets/vocab_card.dart';

class AssemblyScreen extends ConsumerStatefulWidget {
  final OrigamiModel model;

  const AssemblyScreen({
    super.key,
    required this.model,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: step.imageUrl.isNotEmpty
                              ? Image.asset(
                                  step.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Column(
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
                                )
                              : Column(
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
                        ...step.vocabList.map((v) => VocabCard(vocab: v)),
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
