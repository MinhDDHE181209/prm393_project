import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

// ─── Enum loại user ──────────────────────────────────────────────────────────
enum UserType { guest, free, premium }

// ─── AuthService singleton ───────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userServiceProvider = Provider<UserService>((ref) => UserService());

// ─── Stream trạng thái đăng nhập Firebase ────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── Kiểm tra isGuest từ SharedPreferences ───────────────────────────────────
final isGuestProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.keyIsGuest) ?? false;
});

// ─── isPremium từ Firestore ──────────────────────────────────────────────────
final isPremiumProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(false);
  return ref.watch(userServiceProvider).isPremiumStream(user.uid);
});

// ─── UserType tổng hợp: guest / free / premium ───────────────────────────────
final userTypeProvider = Provider<UserType>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final isGuest = ref.watch(isGuestProvider).valueOrNull ?? false;
  final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;

  if (user != null) {
    return isPremium ? UserType.premium : UserType.free;
  }
  if (isGuest) return UserType.guest;
  return UserType.guest;
});

// ─── UID tiện dụng ───────────────────────────────────────────────────────────
final currentUidProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user?.uid ?? 'guest';
});

// ─── Display name tiện dụng ──────────────────────────────────────────────────
final displayNameProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final userType = ref.watch(userTypeProvider);
  if (userType == UserType.guest) return 'Khách';
  return user?.displayName ?? user?.email?.split('@').first ?? 'Người dùng';
});

// ─── Phân quyền truy cập ─────────────────────────────────────────────────────
extension UserTypeAccess on UserType {
  bool get canSaveProgress => this != UserType.guest;
  bool get canUseWordVault => this != UserType.guest;
  bool get unlocksAllCollections => this == UserType.premium;
}

/// Đồng bộ document Firestore khi user đăng nhập.
final userDocSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
    final user = next.valueOrNull;
    if (user != null) {
      ref.read(userServiceProvider).ensureUserDocument(user);
    }
  });
});
