import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../models/vocabulary.dart';
import '../providers/vocab_provider.dart';
import '../providers/auth_provider.dart';

class WordVaultScreen extends ConsumerStatefulWidget {
  const WordVaultScreen({super.key});

  @override
  ConsumerState<WordVaultScreen> createState() => _WordVaultScreenState();
}

class _WordVaultScreenState extends ConsumerState<WordVaultScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    final filter   = ref.watch(vocabFilterProvider);
    final filteredAsync = ref.watch(filteredVocabProvider);

    if (userType == UserType.guest) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: _GuestPlaceholder(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kanji, romaji, nghĩa...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  selected: filter == VocabFilter.all,
                  onTap: () => ref.read(vocabFilterProvider.notifier).state = VocabFilter.all,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cần ôn 🔴',
                  selected: filter == VocabFilter.needsReview,
                  onTap: () => ref.read(vocabFilterProvider.notifier).state = VocabFilter.needsReview,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Đã thuộc ✅',
                  selected: filter == VocabFilter.learned,
                  onTap: () => ref.read(vocabFilterProvider.notifier).state = VocabFilter.learned,
                ),
              ],
            ),
          ),

          // Word list
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.amber)),
              error: (e, _) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: Colors.red))),
              data: (words) {
                final filtered = _searchQuery.isEmpty
                    ? words
                    : words.where((w) =>
                        w.kanji.toLowerCase().contains(_searchQuery) ||
                        w.romaji.toLowerCase().contains(_searchQuery) ||
                        w.meaningVi.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(filter: filter, hasSearch: _searchQuery.isNotEmpty);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Text('${filtered.length} từ',
                              style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          const Spacer(),
                          if (filter == VocabFilter.needsReview && filtered.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _startQuickReview(context, filtered),
                              icon: const Icon(Icons.flash_on, size: 16, color: AppTheme.amber),
                              label: const Text('Ôn tập nhanh',
                                  style: TextStyle(color: AppTheme.amber, fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _VocabTile(word: filtered[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: const Row(
        children: [
          Text('📖', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Word Vault',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      actions: [
        Consumer(builder: (context, ref, _) {
          final count = ref.watch(reviewCountProvider);
          if (count == 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text('$count cần ôn',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: Colors.red.shade700,
              padding: EdgeInsets.zero,
            ),
          );
        }),
      ],
    );
  }

  void _startQuickReview(BuildContext context, List<VocabWord> words) {
    // TODO Phase 7: mở quiz riêng với words này
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ôn tập ${words.length} từ — hoàn thiện ở Phase 7'),
        backgroundColor: AppTheme.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── VocabTile ─────────────────────────────────────────────────────────────────
class _VocabTile extends ConsumerWidget {
  final VocabWord word;
  const _VocabTile({required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vocabNotifierProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: word.needsReview
              ? Colors.red.withValues(alpha: 0.3)
              : AppTheme.teal.withValues(alpha: 0.3),
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
                    ? Colors.red.withValues(alpha: 0.15)
                    : AppTheme.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.needsReview ? 'Cần ôn' : 'Đã thuộc',
                style: TextStyle(
                  color: word.needsReview ? Colors.red.shade300 : AppTheme.teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => word.needsReview
                  ? notifier.markReviewed(word.kanji)
                  : notifier.markNeedsReview(word.kanji),
              child: Icon(
                word.needsReview ? Icons.check_circle_outline : Icons.refresh,
                color: word.needsReview ? AppTheme.teal : Colors.white38,
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

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.amber : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.amber : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white60,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Empty / Guest states ──────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VocabFilter filter;
  final bool hasSearch;
  const _EmptyState({required this.filter, required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    final icon = hasSearch ? '🔍'
        : filter == VocabFilter.needsReview ? '🎉'
        : filter == VocabFilter.learned ? '📚' : '⭐';
    final title = hasSearch ? 'Không tìm thấy'
        : filter == VocabFilter.needsReview ? 'Không có từ cần ôn!'
        : filter == VocabFilter.learned ? 'Chưa có từ đã thuộc' : 'Word Vault trống';
    final sub = hasSearch ? 'Thử từ khoá khác'
        : filter == VocabFilter.needsReview ? 'Bạn đã thuộc hết rồi 🎊'
        : filter == VocabFilter.learned ? 'Hoàn thành quiz để đánh dấu từ'
        : 'Tap từ JP gạch chân khi gấp để lưu';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }
}

class _GuestPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text('Đăng ký để lưu từ vựng',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Tạo tài khoản miễn phí để lưu từ JP và theo dõi tiến độ học',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              child: const Text(
  'Đăng ký ngay', 
  style: TextStyle(fontWeight: FontWeight.bold), //  Đúng
),
            ),
          ],
        ),
      ),
    );
  }
}
