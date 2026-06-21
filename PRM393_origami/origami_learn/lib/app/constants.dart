/// Các hằng số dùng chung trong toàn app.
/// Không đặt logic ở đây — chỉ giá trị cố định.
class AppConstants {
  AppConstants._(); // không cho khởi tạo

  // ── Gamification ──
  static const int xpPerStep = 5;
  static const int xpPerCompleteModel = 50;
  static const int xpPerCorrectQuizAnswer = 10;

  // Level lên mỗi 200 XP (tuỳ chỉnh sau nếu cần cong hơn)
  static const int xpPerLevel = 200;

  // ── Streak ──
  static const int streakGraceHours = 36; // cho phép trễ tối đa 36h vẫn giữ streak

  // ── SharedPreferences keys ──
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyIsGuest = 'is_guest';
  static const String keySelectedPaperColor = 'selected_paper_color';

  // ── SQLite ──
  static const String dbName = 'origami_learn.db';
  static const int dbVersion = 1;

  // ── Demo account (dùng để bảo vệ báo cáo) ──
  static const String demoEmail = 'demo@origamilearn.app';
}
