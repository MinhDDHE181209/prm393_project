import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/vocab_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType       = ref.watch(userTypeProvider);
    final displayName    = ref.watch(displayNameProvider);
    final progressAsync  = ref.watch(userProgressProvider);
    final vocabCount     = ref.watch(vocabCountProvider);
    final firebaseUser   = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Hồ sơ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (userType != UserType.guest)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white54),
              tooltip: 'Đăng xuất',
              onPressed: () => _confirmSignOut(context, ref),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: progressAsync.when(
          loading: () => const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
          ),
          error: (e, _) => Center(
              child: Text('Lỗi: $e', style: const TextStyle(color: Colors.red))),
          data: (progress) => Column(
            children: [
              // ── Avatar + tên ──
              _AvatarSection(
                displayName: displayName,
                email: firebaseUser?.email,
                photoUrl: firebaseUser?.photoURL,
                userType: userType,
              ),
              const SizedBox(height: 24),

              // ── Level + XP bar ──
              _LevelCard(
                level: progress.level,
                xpInLevel: progress.xpInCurrentLevel,
                levelProgress: progress.levelProgress,
                totalXP: progress.totalXP,
              ),
              const SizedBox(height: 16),

              // ── Stats row ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: '🔥',
                      value: '${progress.streak}',
                      label: 'Ngày streak',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: '📖',
                      value: '$vocabCount',
                      label: 'Từ đã lưu',
                      color: AppTheme.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: '🦢',
                      value: '${progress.modelsCompleted}',
                      label: 'Mẫu hoàn thành',
                      color: AppTheme.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Badges ──
              _BadgesSection(modelsCompleted: progress.modelsCompleted),
              const SizedBox(height: 16),

              // ── Guest CTA ──
              if (userType == UserType.guest) _GuestCTA(),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Đăng xuất?', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn sẽ được chuyển về màn hình đăng nhập.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
              if (context.mounted) context.go('/auth');
            },
            child: Text('Đăng xuất', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Section ────────────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final String displayName;
  final String? email;
  final String? photoUrl;
  final UserType userType;

  const _AvatarSection({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.amber, width: 3),
            color: AppTheme.surface,
          ),
          child: photoUrl != null
              ? ClipOval(
                  child: Image.network(photoUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _DefaultAvatar(displayName)))
              : _DefaultAvatar(displayName),
        ),
        const SizedBox(height: 12),
        Text(displayName,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        if (email != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(email!,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
        const SizedBox(height: 8),
        // User type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _badgeColor(userType).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _badgeColor(userType).withValues(alpha: 0.5)),
          ),
          child: Text(
            _badgeLabel(userType),
            style: TextStyle(
                color: _badgeColor(userType),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _badgeColor(UserType t) => switch (t) {
        UserType.premium => AppTheme.amber,
        UserType.free => AppTheme.teal,
        UserType.guest => Colors.white38,
      };

  String _badgeLabel(UserType t) => switch (t) {
        UserType.premium => '⭐ Premium',
        UserType.free => '🆓 Free',
        UserType.guest => '👤 Khách',
      };
}

class _DefaultAvatar extends StatelessWidget {
  final String name;
  const _DefaultAvatar(this.name);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: AppTheme.amber, fontSize: 36, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Level Card ────────────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final int level;
  final int xpInLevel;
  final double levelProgress;
  final int totalXP;

  const _LevelCard({
    required this.level,
    required this.xpInLevel,
    required this.levelProgress,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$level',
                      style: const TextStyle(
                          color: AppTheme.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level $level',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text('$xpInLevel / 200 XP',
                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              Text('$totalXP XP tổng',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          // XP Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: levelProgress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Còn ${200 - xpInLevel} XP nữa lên Level ${level + 1}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Badges Section ────────────────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  final int modelsCompleted;
  const _BadgesSection({required this.modelsCompleted});

  static const _badges = [
    (icon: '🦢', label: 'Con Hạc', threshold: 1),
    (icon: '⭐', label: 'Bắt đầu', threshold: 3),
    (icon: '🔥', label: 'Chuyên cần', threshold: 5),
    (icon: '🌸', label: 'Hoa Đào', threshold: 8),
    (icon: '🐉', label: 'Rồng thiêng', threshold: 12),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Huy hiệu',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _badges.map((b) {
              final unlocked = modelsCompleted >= b.threshold;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? AppTheme.amber.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: unlocked
                            ? AppTheme.amber.withValues(alpha: 0.6)
                            : Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unlocked ? b.icon : '🔒',
                        style: TextStyle(
                            fontSize: 22,
                            color: unlocked ? null : Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.label,
                    style: TextStyle(
                      color: unlocked ? Colors.white70 : Colors.white24,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${b.threshold} mẫu',
                    style: const TextStyle(color: Colors.white24, fontSize: 9),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Guest CTA ─────────────────────────────────────────────────────────────────
class _GuestCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('Lưu tiến độ của bạn',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Đăng ký để XP và streak của bạn không bị mất khi tắt app',
            style: TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go('/auth'),
              child: const Text('Đăng ký miễn phí'),
            ),
          ),
        ],
      ),
    );
  }
}
