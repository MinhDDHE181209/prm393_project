import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/fold_step.dart';

class VocabCard extends StatelessWidget {
  final VocabRef vocab;

  const VocabCard({super.key, required this.vocab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
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
      ]),
    );
  }
}
