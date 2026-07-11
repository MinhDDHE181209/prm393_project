import 'package:flutter/material.dart';
import '../providers/vocab_provider.dart';

class WordVaultEmptyState extends StatelessWidget {
  final VocabFilter filter;
  final bool hasSearch;

  const WordVaultEmptyState({
    super.key,
    required this.filter,
    required this.hasSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (hasSearch) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Text('Không tìm thấy từ vựng nào phù hợp',
            style: TextStyle(color: Colors.white54)),
      );
    }
    
    final msg = filter == VocabFilter.all
        ? 'Kho từ vựng của bạn đang trống.\nHãy lưu từ khi học các mẫu Origami nhé!'
        : filter == VocabFilter.needsReview
            ? 'Tuyệt vời, bạn không có từ nào cần ôn lúc này!'
            : 'Bạn chưa có từ vựng nào thuộc nhóm này.';
            
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Icon(
            filter == VocabFilter.needsReview
                ? Icons.check_circle_outline
                : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.white12,
          ),
          const SizedBox(height: 16),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, height: 1.5)),
        ],
      ),
    );
  }
}

class GuestPlaceholder extends StatelessWidget {
  const GuestPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('Vui lòng đăng nhập\nđể sử dụng Word Vault',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
