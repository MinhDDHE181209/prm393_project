import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart'; // ✅ FIX: dùng GoRouter
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/origami_model.dart';
import '../services/vocab_service.dart';
import '../services/progress_service.dart';
// ✅ FIX: bỏ import home_screen.dart — dùng context.go('/home') thay vì Navigator

class CompleteScreen extends StatefulWidget {
  final OrigamiModel model;
  final Color        paperColor;
  final List<String> savedVocabs; // kanji đã lưu trong session

  const CompleteScreen({
    super.key,
    required this.model,
    required this.paperColor,
    required this.savedVocabs,
  });

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _fadeAnim;

  int     _quizIndex    = 0;
  int     _correctCount = 0;
  bool    _quizDone     = false;
  String? _selectedAnswer;
  bool?   _isCorrect;

  late List<_QuizQuestion> _questions;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim =
        CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _questions = _buildQuestions();
    _saveProgress();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Lưu XP + vocab vào SQLite ─────────────────────────────────────────────
  Future<void> _saveProgress() async {
    final uid = _uid;
    if (uid == null) return;

    // Cộng XP hoàn thành model (streak tự tính bên trong addXp)
    await ProgressService().addXP(uid, AppConstants.xpPerCompleteModel);

    // Lưu từng từ vựng đã lưu trong session
    if (widget.savedVocabs.isNotEmpty) {
      final pool    = _mockVocabPool();
      final service = VocabService();
      for (final kanji in widget.savedVocabs) {
        final match = pool.where((v) => v.kanji == kanji).firstOrNull;
        if (match == null) continue;
        await service.saveWord(
          userId:    uid,
          kanji:     match.kanji,
          romaji:    match.romaji,
          meaningVi: match.meaningVi,
          modelId:   widget.model.id,
        );
      }
    }
  }

  // ── Tạo quiz từ vocab session ──────────────────────────────────────────────
  List<_QuizQuestion> _buildQuestions() {
    if (widget.savedVocabs.isEmpty) return [];
    final pool        = _mockVocabPool();
    final sessionVocab = pool
        .where((v) => widget.savedVocabs.contains(v.kanji))
        .toList();
    if (sessionVocab.isEmpty) return [];

    final shuffled  = List<_MockVocab>.from(pool)..shuffle();
    final questions = <_QuizQuestion>[];

    for (final correct in sessionVocab.take(3)) {
      final distractors = shuffled
          .where((v) => v.kanji != correct.kanji)
          .take(3)
          .map((v) => v.meaningVi)
          .toList();
      final options = [...distractors, correct.meaningVi]..shuffle();
      questions.add(_QuizQuestion(
        kanji:         correct.kanji,
        romaji:        correct.romaji,
        correctAnswer: correct.meaningVi,
        options:       options,
      ));
    }
    return questions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _quizDone || _questions.isEmpty
            ? _buildResultView()
            : _buildQuizView(),
      ),
    );
  }

  // ── Màn hình kết quả ──────────────────────────────────────────────────────
  Widget _buildResultView() {
    final xpEarned = AppConstants.xpPerCompleteModel + (_correctCount * AppConstants.xpPerCorrectQuizAnswer);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),

        ScaleTransition(
          scale: _scaleAnim,
          child: const Text('🎉', style: TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 16),

        FadeTransition(
          opacity: _fadeAnim,
          child: Column(children: [
            const Text('Hoàn thành!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.model.nameVi,
                style: const TextStyle(color: Colors.white54, fontSize: 16)),
            Text(widget.model.nameJP,
                style: const TextStyle(color: Colors.white38, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 32),

        // ── XP card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.amber.withValues(alpha: 0.2),
              AppTheme.teal.withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.amber.withValues(alpha: 0.3)),
          ),
          child: Column(children: [
            Text('+$xpEarned XP',
                style: const TextStyle(
                    color: AppTheme.amber,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _XpBreakdown(
                    label: 'Hoàn thành',
                    xp: AppConstants.xpPerCompleteModel),
                if (_correctCount > 0) ...[
                  const Text(' + ',
                      style: TextStyle(color: Colors.white38)),
                  _XpBreakdown(
                      label: 'Quiz ($_correctCount đúng)',
                      xp: _correctCount * AppConstants.xpPerCorrectQuizAnswer),
                ],
              ],
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Từ đã lưu ──
        if (widget.savedVocabs.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⭐ ${widget.savedVocabs.length} từ đã lưu vào Word Vault',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: widget.savedVocabs
                      .map((kanji) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.amber.withValues(alpha: 0.3)),
                            ),
                            child: Text(kanji,
                                style: const TextStyle(
                                    color: AppTheme.amber,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Nút điều hướng ──
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
          // ✅ FIX: dùng GoRouter thay Navigator.pushAndRemoveUntil
          onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Về trang chủ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            // ✅ FIX: dùng context.go('/home') rồi user tự navigate sang Word Vault
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.menu_book_outlined, color: AppTheme.teal),
            label: const Text('Xem Word Vault',
                style: TextStyle(color: AppTheme.teal)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.teal),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Quiz ──────────────────────────────────────────────────────────────────
  Widget _buildQuizView() {
    final q = _questions[_quizIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📝 Ôn từ vựng nhanh',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${_quizIndex + 1}/${_questions.length}',
                style: const TextStyle(color: Colors.white54)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value:      (_quizIndex + 1) / _questions.length,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(AppTheme.amber),
            minHeight:  4,
          ),
          const SizedBox(height: 32),

          Center(
            child: Column(children: [
              Text(q.kanji,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(q.romaji,
                  style: const TextStyle(color: Colors.white54, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Nghĩa của từ này là gì?',
                style: TextStyle(color: Colors.white70, fontSize: 15)),
          ),
          const SizedBox(height: 32),

          ...q.options.map((option) {
            Color borderColor = Colors.white12;
            Color bgColor     = AppTheme.surface;
            Color textColor   = Colors.white;

            if (_selectedAnswer != null) {
              if (option == q.correctAnswer) {
                borderColor = AppTheme.teal;
                bgColor     = AppTheme.teal.withValues(alpha: 0.15);
                textColor   = AppTheme.teal;
              } else if (option == _selectedAnswer && _isCorrect == false) {
                borderColor = Colors.redAccent;
                bgColor     = Colors.redAccent.withValues(alpha: 0.12);
                textColor   = Colors.redAccent;
              }
            }

            return GestureDetector(
              onTap: _selectedAnswer != null
                  ? null
                  : () {
                      final correct = option == q.correctAnswer;
                      setState(() {
                        _selectedAnswer = option;
                        _isCorrect      = correct;
                        if (correct) _correctCount++;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        if (!mounted) return;
                        setState(() {
                          _selectedAnswer = null;
                          _isCorrect      = null;
                          if (_quizIndex < _questions.length - 1) {
                            _quizIndex++;
                          } else {
                            _quizDone = true;
                            _animController.forward(from: 0);
                          }
                        });
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(option,
                        style: TextStyle(color: textColor, fontSize: 15)),
                  ),
                  if (_selectedAnswer != null && option == q.correctAnswer)
                    const Icon(Icons.check_circle,
                        color: AppTheme.teal, size: 20),
                  if (_selectedAnswer == option && _isCorrect == false)
                    const Icon(Icons.cancel,
                        color: Colors.redAccent, size: 20),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<_MockVocab> _mockVocabPool() => [
        _MockVocab('山折り', 'Yamaori', 'Nếp gấp lên (nếp núi)'),
        _MockVocab('谷折り', 'Tanioiri', 'Nếp gấp xuống (nếp thung lũng)'),
        _MockVocab('正方形', 'Seihōkei', 'Hình vuông'),
        _MockVocab('基本形', 'Kihonkei', 'Hình cơ bản'),
        _MockVocab('内折り', 'Uchioiri', 'Gấp vào trong'),
        _MockVocab('首', 'Kubi', 'Cổ'),
        _MockVocab('嘴', 'Kuchibashi', 'Mỏ chim'),
        _MockVocab('翼', 'Tsubasa', 'Cánh'),
      ];
}

// ── Data classes ──────────────────────────────────────────────────────────────
class _QuizQuestion {
  final String       kanji;
  final String       romaji;
  final String       correctAnswer;
  final List<String> options;
  const _QuizQuestion({
    required this.kanji,
    required this.correctAnswer,
    required this.romaji,
    required this.options,
  });
}

class _MockVocab {
  final String kanji;
  final String romaji;
  final String meaningVi;
  const _MockVocab(this.kanji, this.romaji, this.meaningVi);
}

class _XpBreakdown extends StatelessWidget {
  final String label;
  final int    xp;
  const _XpBreakdown({required this.label, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('+$xp XP',
          style: const TextStyle(
              color: AppTheme.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      Text(label,
          style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}