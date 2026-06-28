import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';
import '../services/auth_service.dart';

// ─── Enum loại user ──────────────────────────────────────────────────────────
enum UserType { guest, free, premium }

// ─── AuthService singleton ───────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Stream trạng thái đăng nhập Firebase ────────────────────────────────────
// Trả về User? — null = chưa đăng nhập hoặc đang là guest
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── Kiểm tra isGuest từ SharedPreferences ───────────────────────────────────
final isGuestProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.keyIsGuest) ?? false;
});

// ─── UserType tổng hợp: guest / free / premium ───────────────────────────────
// Logic:
//   • Nếu isGuest == true → guest
//   • Nếu có Firebase user → free (premium check TODO: thêm Firestore field sau)
//   • Không có cả hai → guest (chưa onboard)
final userTypeProvider = Provider<UserType>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final isGuestAsync = ref.watch(isGuestProvider);

  // Trong lúc loading → coi như guest để không block UI
  final user = authAsync.valueOrNull;
  final isGuest = isGuestAsync.valueOrNull ?? false;

  if (user != null) {
    // TODO Phase 7: check Firestore isPremium field → return UserType.premium
    return UserType.free;
  }
  if (isGuest) return UserType.guest;
  return UserType.guest;
});

// ─── UID tiện dụng ───────────────────────────────────────────────────────────
// Trả về uid của Firebase user, hoặc 'guest' nếu là khách
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
