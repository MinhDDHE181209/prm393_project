import 'package:flutter/material.dart';

class S01OnboardingScreen extends StatefulWidget {
  const S01OnboardingScreen({super.key});

  @override
  State<S01OnboardingScreen> createState() => _S01OnboardingScreenState();
}

class _S01OnboardingScreenState extends State<S01OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {"title": "Gấp Giấy Nghệ Thuật", "desc": "Khám phá hàng trăm mẫu Origami từ cơ bản đến phức tạp với hướng dẫn chi tiết.", "icon": "🦢"},
    {"title": "Học Tiếng Nhật Song Hành", "desc": "Tích lũy từ vựng tiếng Nhật chuyên ngành Origami ngay trong lúc thực hành gấp.", "icon": "📖"},
    {"title": "Thử Thách Thăng Cấp", "desc": "Tích lũy XP, duy trì chuỗi Streak học tập và mở khóa nhiều danh hiệu quý giá.", "icon": "🔥"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _slides.length,
                itemBuilder: (context, idx) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_slides[idx]["icon"]!, style: const TextStyle(fontSize: 100)),
                    const SizedBox(height: 30),
                    Text(_slides[idx]["title"]!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _slides[idx]["desc"]!, 
                        textAlign: TextAlign.center, 
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (idx) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: _currentPage == idx ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == idx ? const Color(0xff4083ff) : const Color(0xff202030), 
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4083ff), 
                  minimumSize: const Size.fromHeight(50), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/s02'),
                child: const Text("Đăng nhập / Đăng ký", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/main_tabs'),
              child: const Text("Trải nghiệm ngay (Khách Bypass)", style: TextStyle(color: Color(0xff9292a9))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}