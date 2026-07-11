import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/theme.dart';
import '../models/collection_model.dart';
import '../widgets/collection_card.dart';
import '../widgets/continue_folding_card.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../app/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/fold_session_provider.dart';
import 'word_vault_screen.dart';
import 'profile_screen.dart';
import 'payment_bottom_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
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
    ref.invalidate(inProgressSessionProvider);
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
    final inProgressAsync = ref.watch(inProgressSessionProvider);
    final _inProgressModel = inProgressAsync.valueOrNull;

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
              if (_inProgressModel != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ContinueFoldingCard(
                      data: _inProgressModel,
                      onTap: () {
                        final model = _inProgressModel.model;
                        final colorQuery = AppRouter.paperColorQuery(
                            const Color(0xFFE53935));
                        if (model.type == 'step') {
                          context
                              .pushNamed(
                                AppRoutes.foldStep,
                                pathParameters: {'modelId': model.id},
                                queryParameters: {
                                  AppRoutes.paperColorQuery: colorQuery,
                                },
                              )
                              .then((_) => ref.invalidate(inProgressSessionProvider));
                        } else {
                          context
                              .pushNamed(
                                AppRoutes.foldModule,
                                pathParameters: {'modelId': model.id},
                                queryParameters: {
                                  AppRoutes.paperColorQuery: colorQuery,
                                },
                              )
                              .then((_) => ref.invalidate(inProgressSessionProvider));
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
                      return CollectionCard(
                        collection: c,
                        onTap: () async {
                          final userType = ref.read(userTypeProvider);
                          if (!c.isUnlocked &&
                              c.price > 0 &&
                              !userType.unlocksAllCollections) {
                            await PaymentBottomSheet.show(context, ref, collection: c);
                            return;
                          }
                          context.pushNamed(
                            AppRoutes.collectionDetail,
                            pathParameters: {'collectionId': c.id},
                            extra: c,
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
