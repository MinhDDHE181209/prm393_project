import 'package:flutter/material.dart';

class S12CompleteQuizScreen extends StatefulWidget {
  const S12CompleteQuizScreen({super.key});

  @override
  State<S12CompleteQuizScreen> createState() => _S12CompleteQuizScreenState();
}

class _S12CompleteQuizScreenState extends State<S12CompleteQuizScreen> {
  int? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final answers = [
      "Gấp nếp núi (Lồi lên)",
      "Gấp nếp thung lũng (Lõm xuống)",
      "Cắt đôi tờ giấy",
      "Lật ngược mặt sau giấy"
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity, height: 20),
              const Text("🎉 HOÀN THÀNH XUẤT SẮC! 🎉", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 12),
              const Text("Bạn đã được cộng +50 XP vào Tiến Trình (S04)", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xff0e0e14), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xff202030))),
                child: Column(
                  children: [
                    const Text("🎯 QUIZ ÔN TẬP TIẾNG NHẬT NHANH", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    const Text("Thuật ngữ '山折り (Yamaori)' vừa học ở S09 có nghĩa là gì?", style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ...List.generate(4, (idx) {
                      return Card(
                        color: const Color(0xff14141e),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: RadioListTile<int>(
                          title: Text(answers[idx], style: const TextStyle(fontSize: 14)),
                          value: idx,
                          groupValue: selectedAnswer,
                          onChanged: (val) {
                            setState(() {
                              selectedAnswer = val;
                            });
                          },
                        ),
                      );
                    })
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4083ff), minimumSize: const Size.fromHeight(52)),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/main_tabs', (route) => false);
                },
                child: const Text("Nộp bài & Về Trang Chủ Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}