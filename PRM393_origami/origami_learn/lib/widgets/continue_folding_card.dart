import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../providers/fold_session_provider.dart';

class ContinueFoldingCard extends StatelessWidget {
  final InProgressData data;
  final VoidCallback onTap;
  
  const ContinueFoldingCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.teal.withOpacity(0.3), AppTheme.amber.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.teal.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tiếp tục gấp',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.model.nameVi,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    data.model.nameJP,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: data.percent,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.amber),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(data.percent * 100).toInt()}% hoàn thành',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle_fill, color: AppTheme.amber, size: 36),
          ],
        ),
      ),
    );
  }
}
