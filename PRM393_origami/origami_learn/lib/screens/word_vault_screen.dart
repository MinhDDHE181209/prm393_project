import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/routes.dart';
import '../app/theme.dart';
import '../models/vocabulary.dart';
import '../providers/auth_provider.dart';
import '../providers/vocab_provider.dart';
import '../widgets/custom_filter_chip.dart';
import '../widgets/vocab_tile.dart';
import '../widgets/word_vault_empty_state.dart';

class WordVaultScreen extends ConsumerStatefulWidget {
  const WordVaultScreen({super.key});

  @override
  ConsumerState<WordVaultScreen> createState() => _WordVaultScreenState();
}

class _WordVaultScreenState extends ConsumerState<WordVaultScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    final filter   = ref.watch(vocabFilterProvider);


    if (userType == UserType.guest || !userType.canUseWordVault) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: const GuestPlaceholder(),
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
                suffixIcon: ref.watch(vocabSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(vocabSearchQueryProvider.notifier).state = '';
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
              onChanged: (v) => ref.read(vocabSearchQueryProvider.notifier).state = v.trim().toLowerCase(),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CustomFilterChip(
                  label: 'Tất cả',
                  selected: filter == VocabFilter.all,
                  onTap: () => ref.read(vocabFilterProvider.notifier).state = VocabFilter.all,
                ),
                const SizedBox(width: 8),
                CustomFilterChip(
                  label: 'Cần ôn 🔴',
                  selected: filter == VocabFilter.needsReview,
                  onTap: () => ref.read(vocabFilterProvider.notifier).state = VocabFilter.needsReview,
                ),
                const SizedBox(width: 8),
                CustomFilterChip(
                  label: 'Đã thuộc ✅',
                  selected: filter == VocabFilter.learned,
                  onTap: () => ref.read(vocabFilterProvider.notifier).state = VocabFilter.learned,
                ),
              ],
            ),
          ),

          // Word list
          Expanded(
            child: ref.watch(groupedVocabsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.amber)),
              error: (e, _) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: Colors.red))),
              data: (groups) {
                final searchQuery = ref.watch(vocabSearchQueryProvider);
                if (groups.isEmpty) {
                  return WordVaultEmptyState(filter: filter, hasSearch: searchQuery.isNotEmpty);
                }

                final totalWords = groups.fold<int>(0, (sum, g) => sum + g.words.length);
                final allMatchedWords = groups.expand((g) => g.words).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Text('$totalWords từ',
                              style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          const Spacer(),
                          if (filter == VocabFilter.needsReview && totalWords > 0)
                            TextButton.icon(
                              onPressed: () => _startQuickReview(context, allMatchedWords),
                              icon: const Icon(Icons.flash_on, size: 16, color: AppTheme.amber),
                              label: const Text('Ôn tập nhanh',
                                  style: TextStyle(color: AppTheme.amber, fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: groups.length,
                        itemBuilder: (context, groupIdx) {
                          final g = groups[groupIdx];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group Header (Tên Collection)
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(g.collection.emoji, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          g.collection.title,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${g.words.length} từ',
                                        style: const TextStyle(color: Colors.white30, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Danh sách từ trong group
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: g.words.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, wordIdx) => VocabTile(word: g.words[wordIdx]),
                              ),
                            ],
                          );
                        },
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
        final status = ref.watch(vocabSyncNotifierProvider);
        return IconButton(
          icon: status == SyncStatus.syncing
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.amber),
                )
              : Icon(
                  status == SyncStatus.error ? Icons.cloud_off : Icons.cloud_sync,
                  color: status == SyncStatus.error ? Colors.red.shade300 : Colors.white70,
                ),
          tooltip: 'Đồng bộ Word Vault',
          onPressed: status == SyncStatus.syncing
              ? null
              : () async {
                  final notifier = ref.read(vocabSyncNotifierProvider.notifier);
                  await notifier.sync();
                  if (!context.mounted) return;
                  final ok = ref.read(vocabSyncNotifierProvider) == SyncStatus.success;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Đồng bộ thành công: ${notifier.lastResult?.pushedCount ?? 0} từ đẩy lên, ${notifier.lastResult?.pulledCount ?? 0} từ tải về'
                        : 'Lỗi đồng bộ: ${notifier.lastError ?? "không rõ"}'),
                    backgroundColor: ok ? AppTheme.teal : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
        );
      }),
      Consumer(builder: (context, ref, _) {
        final count = ref.watch(reviewCountProvider);
        final uid = ref.watch(currentUidProvider);
        if (uid == 'guest' || count == 0) return const SizedBox.shrink();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ôn tập ${words.length} từ — hoàn thiện ở Phase 7'),
        backgroundColor: AppTheme.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
