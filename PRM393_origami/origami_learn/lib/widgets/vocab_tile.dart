import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../models/vocabulary.dart';
import '../providers/vocab_provider.dart';

class VocabTile extends ConsumerWidget {
  final VocabWord word;
  const VocabTile({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vocabNotifierProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: word.needsReview
              ? Colors.red.withOpacity(0.3)
              : AppTheme.teal.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(word.kanji,
                style: const TextStyle(
                    color: AppTheme.amber, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(word.romaji, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(word.meaningVi,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: word.needsReview
                    ? Colors.red.withOpacity(0.15)
                    : AppTheme.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.isDueForReview ? 'Cần ôn' : 'Đã thuộc',
                style: TextStyle(
                  color: word.isDueForReview ? Colors.red.shade300 : AppTheme.teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => word.isDueForReview
                  ? notifier.markReviewed(word.kanji, quality: 4)
                  : notifier.markNeedsReview(word.kanji),
              child: Icon(
                word.isDueForReview ? Icons.check_circle_outline : Icons.refresh,
                color: word.isDueForReview ? AppTheme.teal : Colors.white38,
                size: 22,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _confirmDelete(context, ref),
              child: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Xoá từ?', style: TextStyle(color: Colors.white)),
        content: Text('Xoá "${word.kanji}" khỏi Word Vault?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(vocabNotifierProvider.notifier).removeWord(word.kanji);
              Navigator.pop(context);
            },
            child: Text('Xoá', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }
}
