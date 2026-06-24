import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';
import '../../app/theme.dart';
import '../../models/collection_model.dart';
import '../../services/origami_service.dart';
import 'package:flutter/material.dart';
import 'package:origami_learn/screens/collection_detail_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = OrigamiService();
  late Future<List<CollectionModel>> _collectionsFuture;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _service.getCollections();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuest = prefs.getBool(AppConstants.keyIsGuest) ?? false;
    });
  }

  void _showAuthRequiredDialog(String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Yêu cầu đăng nhập 🔑', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Tính năng "$featureName" chỉ dành cho thành viên đã đăng ký. Bạn có muốn đăng nhập ngay?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/auth');
            },
            child: const Text('Đăng nhập', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OrigamiLearn 🦢'),
        actions: [
          IconButton(
            icon: Icon(_isGuest ? Icons.login_rounded : Icons.person_outline),
            onPressed: () {
              if (_isGuest) {
                context.go('/auth');
              } else {
                // TODO: context.go('/profile') khi S04 xong
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CollectionModel>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.amber),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Không tải được dữ liệu.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          final collections = snapshot.data ?? [];
          return CustomScrollView(
            slivers: [
              if (_isGuest)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.amber, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Bạn đang trải nghiệm với tư cách Khách. Đăng nhập để lưu tiến trình và học từ vựng!',
                            style: TextStyle(color: AppTheme.amber, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/auth'),
                          child: const Text('Đăng ký', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final col = collections[index];
                      return _CollectionCard(
                        collection: col,
                        isGuest: _isGuest,
                        onAuthRequired: () => _showAuthRequiredDialog(col.title),
                      );
                    },
                    childCount: collections.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final bool isGuest;
  final VoidCallback onAuthRequired;

  const _CollectionCard({
    required this.collection,
    required this.isGuest,
    required this.onAuthRequired,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CollectionDetailScreen(collection: collection),
    ),
  );
},
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        collection.emoji,
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                  ),
                  // Khách thì chỉ mở khoá bộ đầu tiên, các bộ khác tự động hiển thị khoá
                  if ((isGuest && collection.id != '1') || (!isGuest && !collection.isUnlocked))
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.lock, color: Colors.white60, size: 18),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    collection.titleJP,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: collection.price == 0
                          ? AppTheme.teal.withOpacity(0.2)
                          : AppTheme.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      collection.price == 0
                          ? 'Miễn phí'
                          : '${collection.price}đ',
                      style: TextStyle(
                        color: collection.price == 0
                            ? AppTheme.teal
                            : AppTheme.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
