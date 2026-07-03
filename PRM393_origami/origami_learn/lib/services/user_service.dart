import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore layer cho hồ sơ user (`users/{uid}`).
class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<bool> isPremiumStream(String uid) {
    return _doc(uid).snapshots().map(
          (snap) => snap.data()?['isPremium'] == true,
        );
  }

  Future<bool> getIsPremium(String uid) async {
    final snap = await _doc(uid).get();
    return snap.data()?['isPremium'] == true;
  }

  /// Tạo hoặc merge document khi đăng ký / đăng nhập.
  Future<void> ensureUserDocument(User user) async {
    await _doc(user.uid).set(
      {
        'email': user.email,
        'displayName': user.displayName,
        'isPremium': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setPremium(String uid, {required bool isPremium}) async {
    await _doc(uid).set(
      {
        'isPremium': isPremium,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
