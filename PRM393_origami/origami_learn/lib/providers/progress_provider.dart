import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';
import 'auth_provider.dart';

// ─── Service ─────────────────────────────────────────────────────────────────
final progressServiceProvider =
    Provider<ProgressService>((ref) => ProgressService());

// ─── UserProgress cho user hiện tại ─────────────────────────────────────────
// Tự động re-fetch khi uid thay đổi (login/logout)
final userProgressProvider =
    FutureProvider.autoDispose<UserProgress>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == 'guest') {
    // Guest không có SQLite record — trả về default
    return const UserProgress(userId: 'guest');
  }
  final service = ref.read(progressServiceProvider);
  return service.getProgress(uid);
});

// ─── Helpers derived từ userProgressProvider ─────────────────────────────────
final totalXpProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(userProgressProvider).valueOrNull?.totalXP ?? 0;
});

final levelProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(userProgressProvider).valueOrNull?.level ?? 1;
});

final streakProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(userProgressProvider).valueOrNull?.streak ?? 0;
});

final levelProgressProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(userProgressProvider).valueOrNull?.levelProgress ?? 0.0;
});

final modelsCompletedProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(userProgressProvider).valueOrNull?.modelsCompleted ?? 0;
});

// ─── Notifier để thực hiện actions (addXP, unlock, ...) ─────────────────────
// Sau khi action xong → invalidate userProgressProvider để UI tự refresh
class ProgressNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<UserProgress> addXP(int amount) async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return const UserProgress(userId: 'guest');
    final service = ref.read(progressServiceProvider);
    final result = await service.addXP(uid, amount);
    ref.invalidate(userProgressProvider); // ✅ refresh UI tức thì
    return result;
  }

  Future<void> completeModel() async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return;
    final service = ref.read(progressServiceProvider);
    await service.incrementModelsCompleted(uid);
    await service.updateStreak(uid);
    ref.invalidate(userProgressProvider);
  }

  Future<void> unlockCollection(String collectionId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == 'guest') return;
    final service = ref.read(progressServiceProvider);
    await service.unlockCollection(uid, collectionId);
    ref.invalidate(userProgressProvider);
  }
}

final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, void>(ProgressNotifier.new);
