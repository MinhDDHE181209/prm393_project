import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';

/// Bọc toàn bộ thao tác xác thực. Screen KHÔNG được gọi thẳng FirebaseAuth,
/// luôn đi qua lớp này để dễ test và dễ đổi backend sau này.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream theo dõi trạng thái đăng nhập, dùng cho authProvider.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<bool> get isGuest async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsGuest) ?? false;
  }

  /// Đăng nhập bằng email/password.
  /// Ném AuthException với message tiếng Việt để UI hiển thị trực tiếp.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  /// Đăng ký tài khoản mới bằng email/password.
  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName.trim());
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  /// Đăng nhập Google. Trả về null nếu người dùng huỷ giữa chừng.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user bấm huỷ

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsGuest, false);
  }

  /// Map mã lỗi Firebase sang tiếng Việt dễ hiểu cho người dùng cuối.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai mật khẩu. Vui lòng thử lại.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (cần tối thiểu 6 ký tự).';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'network-request-failed':
        return 'Lỗi mạng. Kiểm tra kết nối Internet.';
      case 'too-many-requests':
        return 'Thử quá nhiều lần. Vui lòng đợi một chút.';
      default:
        return 'Đã có lỗi xảy ra ($code). Vui lòng thử lại.';
    }
  }
}

/// Exception riêng cho Auth, mang sẵn message tiếng Việt để hiển thị thẳng lên UI.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}