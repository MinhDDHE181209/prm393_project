import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:origami_learn/app/constants.dart';
import 'package:origami_learn/app/theme.dart';
import 'package:origami_learn/screens/auth_screen.dart';
import 'package:go_router/go_router.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _slides = const [
    _OnboardData(
      emoji: '🦢',
      title: 'Học gấp Origami',
      desc: 'Từng bước hướng dẫn trực quan, từ cơ bản đến nâng cao.',
    ),
    _OnboardData(
      emoji: '🇯🇵',
      title: 'Học từ vựng tiếng Nhật',
      desc: 'Mỗi nếp gấp đi kèm một từ vựng JP, ghi nhớ tự nhiên.',
    ),
    _OnboardData(
      emoji: '🏆',
      title: 'Tích luỹ kinh nghiệm',
      desc: 'Nhận XP, giữ streak mỗi ngày và mở khoá huy hiệu.',
    ),
  ];



  Future<void> _finishOnboarding({required bool asGuest}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsFirstTime, false);

    if (asGuest) {
      await prefs.setBool(AppConstants.keyIsGuest, true);
    } else {
      await prefs.setBool(AppConstants.keyIsGuest, false);
    }

    if (!mounted) return;

    if (asGuest) {
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _finishOnboarding(asGuest: false),
                child: const Text('Bỏ qua', style: TextStyle(color: Colors.white70)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(slide.emoji, style: const TextStyle(fontSize: 96)),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppTheme.amber : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _slides.length - 1) {
                          _finishOnboarding(asGuest: false);
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(_currentPage == _slides.length - 1
                          ? 'Bắt đầu'
                          : 'Tiếp tục'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _finishOnboarding(asGuest: true),
                    child: const Text(
                      'Trải nghiệm ngay (Guest)',
                      style: TextStyle(color: AppTheme.teal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String emoji;
  final String title;
  final String desc;
  const _OnboardData({required this.emoji, required this.title, required this.desc});
}

/// Placeholder tạm thời cho tới khi S02 (Auth) / S03 (Home) được viết.
/// Xoá widget này khi router.dart được nối thật.
// Hết file onboarding_screen.dart