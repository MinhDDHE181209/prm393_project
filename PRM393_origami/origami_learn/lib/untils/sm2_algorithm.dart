/// SM-2 Spaced Repetition Algorithm
///
/// Based on the SuperMemo SM-2 algorithm (1987).
/// Quality rating: 0-5 (0-2 = fail, 3-5 = pass)
/// - 5: perfect response
/// - 4: correct response after a hesitation
/// - 3: correct response recalled with serious difficulty
/// - 2: incorrect response; where the correct one seemed easy to recall
/// - 1: incorrect response; the correct one remembered
/// - 0: complete blackout
class SM2Algorithm {
  SM2Algorithm._(); // non-instantiable

  static const double _minEaseFactor = 1.3;

  /// Tính lịch ôn tập tiếp theo dựa trên kết quả trả lời.
  ///
  /// [quality]    – mức độ đúng: 0–5
  /// [repetitions] – số lần đã ôn tập liên tiếp thành công
  /// [easeFactor] – hệ số dễ hiện tại (≥ 1.3, khởi tạo = 2.5)
  /// [interval]   – khoảng cách ôn tập hiện tại (ngày)
  ///
  /// Trả về [SM2Result] chứa giá trị mới.
  static SM2Result calculate({
    required int quality,
    required int repetitions,
    required double easeFactor,
    required int interval,
  }) {
    assert(quality >= 0 && quality <= 5, 'quality must be 0-5');

    int newRepetitions;
    int newInterval;
    double newEaseFactor;

    if (quality >= 3) {
      // Đúng — tăng khoảng cách
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * easeFactor).round();
      }
      newRepetitions = repetitions + 1;
    } else {
      // Sai — reset về đầu
      newRepetitions = 0;
      newInterval = 1;
    }

    // Cập nhật easeFactor theo công thức SM-2
    newEaseFactor = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    if (newEaseFactor < _minEaseFactor) {
      newEaseFactor = _minEaseFactor;
    }

    final nextReviewAt = DateTime.now().add(Duration(days: newInterval));

    return SM2Result(
      repetitions: newRepetitions,
      interval: newInterval,
      easeFactor: newEaseFactor,
      nextReviewAt: nextReviewAt,
    );
  }

  /// Kiểm tra xem một từ có cần ôn tập hôm nay không.
  static bool isDue(DateTime nextReviewAt) {
    final now = DateTime.now();
    return nextReviewAt.isBefore(now) ||
        nextReviewAt.day == now.day &&
            nextReviewAt.month == now.month &&
            nextReviewAt.year == now.year;
  }
}

/// Kết quả sau khi chạy SM-2 cho một lần ôn tập.
class SM2Result {
  final int repetitions;
  final int interval; // ngày
  final double easeFactor;
  final DateTime nextReviewAt;

  const SM2Result({
    required this.repetitions,
    required this.interval,
    required this.easeFactor,
    required this.nextReviewAt,
  });

  @override
  String toString() =>
      'SM2Result(reps=$repetitions, interval=${interval}d, ef=${easeFactor.toStringAsFixed(2)}, next=${nextReviewAt.toLocal()})';
}
