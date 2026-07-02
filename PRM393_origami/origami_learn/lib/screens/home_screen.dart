import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/theme.dart';
import '../models/collection_model.dart';
import '../models/origami_model.dart';
import '../services/origami_service.dart';
import '../providers/collection_provider.dart';
import 'collection_detail_screen.dart';
import 'word_vault_screen.dart';
import 'profile_screen.dart';
import 'payment_bottom_sheet.dart';
import 'fold_step_screen.dart';
import 'fold_module_screen.dart';
import '../services/progress_service.dart';

/// Global RouteObserver để HomeScreen biết khi nào được hiển thị lại
final homeRouteObserver = RouteObserver<ModalRoute<void>>();

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  int _currentTab = 0;

  _InProgressData? _inProgressModel;
  final _progressService = ProgressService();
  final _origamiService  = OrigamiService();

  // Tham chiếu tới global observer
  // (không cần static field riêng nữa)

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _loadInProgressSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) homeRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    homeRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Gọi mỗi khi user pop từ màn hình con (fold/complete) về Home
  @override
  void didPopNext() {
    _loadInProgressSession();
  }

  Future<void> _loadInProgressSession() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    final session = await _progressService.getLastSession(uid);
    if (session == null) {
      // Hoàn thành hoặc không có session → ẩn thẻ
      if (mounted) setState(() => _inProgressModel = null);
      return;
    }
    try {
      final modelId = session['model_id'] as String;
      final encoded = session['current_step'] as int;
      final model   = await _origamiService.getModelById(modelId);

      // encoded = modulePart * 1000 + stepPart
      // stepPart là bước hiện tại (0-based index đã +1 khi lưu)
      final stepPart  = encoded % 1000;           // bước trong module
      final total     = model.stepCount > 0 ? model.stepCount : 10;
      final percent   = (stepPart / total).clamp(0.0, 1.0);

      // Chọn emoji dựa trên tên model
      final emoji = _pickEmoji(model.nameVi);

      if (mounted) {
        setState(() {
          _inProgressModel = _InProgressData(
            model:   model,
            emoji:   emoji,
            percent: percent,
          );
        });
      }
    } catch (_) {
      if (mounted) setState(() => _inProgressModel = null);
    }
  }

  String _pickEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('hạc') || n.contains('crane')) return '🦢';
    if (n.contains('bướm') || n.contains('butterfly')) return '🦋';
    if (n.contains('cá') || n.contains('fish')) return '🐟';
    if (n.contains('hoa') || n.contains('flower')) return '🌸';
    if (n.contains('thỏ') || n.contains('rabbit')) return '🐰';
    if (n.contains('khủng long') || n.contains('dino')) return '🦕';
    return '🎏';
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
          const WordVaultScreen(),
          const ProfileScreen(),
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
    final collectionsAsync = ref.watch(collectionsProvider);

    return SafeArea(
      child: collectionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.amber),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Lỗi tải dữ liệu\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (collections) {
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
              // ── Thẻ "Tiếp tục gấp" ──
              if (_inProgressModel != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _ContinueFoldingCard(
                      data: _inProgressModel!,
                      onTap: () {
                        final model = _inProgressModel!.model;
                        if (model.type == 'step') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FoldStepScreen(
                                model: model,
                                paperColor: const Color(0xFFE53935), // màu mặc định
                              ),
                            ),
                          ).then((_) => _loadInProgressSession());
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FoldModuleScreen(
                                model: model,
                                paperColor: const Color(0xFFE53935), // màu mặc định
                              ),
                            ),
                          ).then((_) => _loadInProgressSession());
                        }
                      },
                    ),
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
                      final c = collections[index];
                      return _CollectionCard(
                        collection: c,
                        onTap: () async {
                          if (!c.isUnlocked && c.price > 0) {
                            // Mở S08 Payment
                            await PaymentBottomSheet.show(context, ref, collection: c);
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
                    childCount: collections.length,
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
  final OrigamiModel model;
  final String emoji;
  final double percent;
  
  const _InProgressData({
    required this.model,
    required this.emoji,
    required this.percent,
  });
}

class _ContinueFoldingCard extends StatelessWidget {
  final _InProgressData data;
  final VoidCallback onTap;
  const _ContinueFoldingCard({required this.data, required this.onTap});

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

