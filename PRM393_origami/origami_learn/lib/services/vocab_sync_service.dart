import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';
import 'vocab_service.dart';

/// Đồng bộ 2 chiều Word Vault giữa SQLite (local) và Firestore (cloud).
/// Thiết kế: local luôn là nguồn đọc chính, Firestore chỉ là backup + cầu nối
/// giữa các thiết bị — đồng bộ theo yêu cầu (bấm nút Sync), không realtime.
class VocabSyncService {
  final VocabService _vocabService;
  final FirebaseFirestore _firestore;

  VocabSyncService({
    VocabService? vocabService,
    FirebaseFirestore? firestore,
  })  : _vocabService = vocabService ?? VocabService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _vocabCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('vocabulary');

  /// PUSH: đẩy các từ local chưa sync lên Firestore.
  /// Trả về số từ đã đẩy thành công.
  Future<int> push(String userId) async {
    final unsynced = await _vocabService.getUnsyncedWords(userId);
    if (unsynced.isEmpty) return 0;

    final batch = _firestore.batch();
    for (final word in unsynced) {
      final docRef = _vocabCollection(userId).doc(word.kanji);
      batch.set(docRef, word.toFirestoreMap(), SetOptions(merge: true));
    }
    await batch.commit();

    await _vocabService.markWordsSynced(
      userId,
      unsynced.map((w) => w.kanji).toList(),
    );
    return unsynced.length;
  }

  /// PULL: kéo toàn bộ từ Firestore về, merge vào local theo updatedAt.
  /// Trả về số từ đã được cập nhật/thêm mới vào local.
  Future<int> pull(String userId) async {
    final snapshot = await _vocabCollection(userId).get();
    var count = 0;
    for (final doc in snapshot.docs) {
      final word = VocabWord.fromFirestore(userId, doc.data());
      await _vocabService.upsertFromCloud(word);
      count++;
    }
    return count;
  }

  /// Đồng bộ đầy đủ: Push trước (đẩy cái mới local có) rồi Pull (kéo cái cloud có mà local thiếu).
  /// Đây là hàm chính gọi khi user bấm nút "Sync".
  Future<SyncResult> syncAll(String userId) async {
    final pushed = await push(userId);
    final pulled = await pull(userId);
    return SyncResult(pushedCount: pushed, pulledCount: pulled);
  }
}

class SyncResult {
  final int pushedCount;
  final int pulledCount;
  const SyncResult({required this.pushedCount, required this.pulledCount});
}