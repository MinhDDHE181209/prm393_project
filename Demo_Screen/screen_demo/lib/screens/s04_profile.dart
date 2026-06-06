import 'package:flutter/material.dart';

class S04ProfileScreen extends StatelessWidget {
  const S04ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hồ Sơ Tiến Độ 🔥", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xff0e0e14), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xff202030))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 30, backgroundColor: Colors.orange, child: Text("🔥", style: TextStyle(fontSize: 28))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Cấp độ: Nhật sư Đẳng 8 (Lv.8)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: 0.7, backgroundColor: Colors.black, color: Colors.amber),
                              const SizedBox(height: 4),
                              const Text("750 / 1000 XP để thăng cấp", style: TextStyle(fontSize: 12, color: Color(0xff9292a9))),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 30, color: Color(0xff202030)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: const [Text("🔥 5 Ngày", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)), Text("Streak học", style: TextStyle(fontSize: 12))]),
                        Column(children: const [Text("🏆 12 Cái", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)), Text("Huy hiệu", style: TextStyle(fontSize: 12))]),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text("Bản Đồ Lộ Trình (Origami Roadmap)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Sơ đồ Roadmap dạng cây kỹ năng
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, idx) {
                  final checkpoints = [
                    {"title": "Mốc 1: Nhập môn Chim Hạc Giấy", "icon": "🎯", "done": true},
                    {"title": "Mốc 2: Lắp ráp Module Phi Thuyền", "icon": "🧩", "done": false},
                    {"title": "Mốc 3: Hoa Anh Đào Phức Tạp", "icon": "🌸", "done": false},
                  ];
                  final cp = checkpoints[idx];
                  return Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(backgroundColor: cp["done"] == true ? const Color(0xff1ebd59) : const Color(0xff202030), child: Text(cp["icon"]!.toString())),
                          if (idx != 2) Container(width: 3, height: 50, color: const Color(0xff202030)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          color: const Color(0xff0e0e14),
                          child: ListTile(
                            title: Text(cp["title"]!.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: cp["done"] == true ? Colors.white : Colors.grey)),
                            subtitle: Text(cp["done"] == true ? "Đã mở khóa - Nhấn để vào gấp" : "🔒 Đang khóa", style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                            onTap: () => Navigator.pushNamed(context, '/s07'),
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}