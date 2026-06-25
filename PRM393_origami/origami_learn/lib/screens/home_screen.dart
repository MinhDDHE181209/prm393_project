import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
import '../../models/collection_model.dart';
import '../../services/origami_service.dart';
import 'collection_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = OrigamiService();
  late Future<List<CollectionModel>> _collectionsFuture;
  int _currentTab = 0;

  // Demo: mẫu đang gấp dở (sau này lấy từ SQLite)
  final _inProgressModel = _InProgressData(
    name: 'Con hạc giấy',
    nameJP: '折り鶴',
    emoji: '🦢',
    percent: 0.4, // 40%
  );

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _service.getCollections();
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeTab(),
          const _PlaceholderTab(icon: Icons.menu_book_outlined, label: 'Word Vault\n(S05 - chưa làm)'),
          const _PlaceholderTab(icon: Icons.person_outline, label: 'Hồ sơ\n(S04 - chưa làm)'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.amber.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.amber),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppTheme.amber),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.amber),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: FutureBuilder<List<CollectionModel>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              // ── AppBar chào mừng + avatar ──
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.background,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    Text(
                      _currentUser?.displayName ?? 'Khách',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.amber,
                      backgroundImage: _currentUser?.photoURL != null
                          ? NetworkImage(_currentUser!.photoURL!)
                          : null,
                      child: _currentUser?.photoURL == null
                          ? Text(
                              (_currentUser?.displayName ?? 'K')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              // ── Thẻ "Tiếp tục gấp" ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _ContinueFoldingCard(data: _inProgressModel),
                ),
              ),

              // ── Tiêu đề "Bộ sưu tập" ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Bộ sưu tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ── Grid 2 cột ──
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.amber),
                  ),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Lỗi tải dữ liệu\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = snapshot.data![index];
                        return _CollectionCard(
                          collection: c,
                          onTap: () {
                            if (!c.isUnlocked && c.price > 0) {
                              // TODO: mở S08 Payment khi đến Phase 6
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🔒 "${c.title}" cần mở khoá (${c.price}đ)'),
                                  backgroundColor: Colors.black87,
                                  action: SnackBarAction(
                                    label: 'Mở khoá',
                                    textColor: AppTheme.amber,
                                    onPressed: () {
                                      // TODO: context.push('/payment/${c.id}')
                                    },
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CollectionDetailScreen(collection: c),
                              ),
                            );
                          },
                        );
                      },
                      childCount: snapshot.data?.length ?? 0,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Thẻ tiếp tục gấp ──────────────────────────────────────────────────────────
class _InProgressData {
  final String name;
  final String nameJP;
  final String emoji;
  final double percent; // 0.0 – 1.0
  const _InProgressData({
    required this.name,
    required this.nameJP,
    required this.emoji,
    required this.percent,
  });
}

class _ContinueFoldingCard extends StatelessWidget {
  final _InProgressData data;
  const _ContinueFoldingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  data.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  data.nameJP,
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
    );
  }
}

// ── Collection Card ────────────────────────────────────────────────────────────
class _CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final VoidCallback onTap;
  const _CollectionCard({required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = !collection.isUnlocked && collection.price > 0;
    return GestureDetector(
      onTap: onTap,
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
                    decoration: BoxDecoration(
                      color: locked ? Colors.black45 : Colors.black26,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        collection.emoji,
                        style: TextStyle(
                          fontSize: 52,
                          color: locked ? Colors.white38 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (locked)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.lock, color: Colors.white60, size: 20),
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
                    style: TextStyle(
                      color: locked ? Colors.white38 : Colors.white,
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
                          ? '🔓 Miễn phí'
                          : locked
                              ? '🔒 ${collection.price}đ'
                              : '✅ Đã mở khoá',
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

// ── Placeholder cho tab chưa làm ──────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}