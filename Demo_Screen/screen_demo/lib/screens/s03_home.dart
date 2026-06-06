import 'package:flutter/material.dart';
import 's08_mock_payment.dart';

class S03HomeScreen extends StatelessWidget {
  const S03HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = [
      {"name": "Chủ đề Loài Chim", "icon": "🐦", "status": "Free", "count": "8 mẫu gấp"},
      {"name": "Phương Tiện Giao Thông", "icon": "🚗", "status": "🔒 Khóa", "count": "12 mẫu gấp"},
      {"name": "Thế Giới Loài Hoa", "icon": "🌸", "status": "Free", "count": "6 mẫu gấp"},
      {"name": "Sinh Vật Biển Đóng Khóa", "icon": "🐋", "status": "🔒 Khóa", "count": "10 mẫu gấp"},
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chào bạn học! 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Hôm nay bạn muốn gấp hình gì?", style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const CircleAvatar(backgroundColor: Color(0xff4083ff), child: Text("U"))
                ],
              ),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xff14141e),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xff202030))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text("🦢", style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tiếp tục gấp: Con Hạc Giấy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            const LinearProgressIndicator(value: 0.45, backgroundColor: Colors.black26, color: Color(0xff1ebd59)),
                            const SizedBox(height: 4),
                            const Text("Tiến độ: 45% (Bước 5/12)", style: TextStyle(fontSize: 12, color: Color(0xff9292a9))),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.play_arrow_rounded, color: Colors.green), onPressed: () => Navigator.pushNamed(context, '/s09'))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text("Bộ Sưu Tập Origami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.1),
                itemCount: collections.length,
                itemBuilder: (context, idx) {
                  final col = collections[idx];
                  bool isLocked = col["status"]!.contains("Khóa");
                  return InkWell(
                    onTap: () {
                      if (isLocked) {
                        showModalBottomSheet(context: context, builder: (ctx) => S08MockPaymentSheet(title: col["name"]!));
                      } else {
                        Navigator.pushNamed(context, '/s06');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xff0e0e14), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xff202030))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(col["icon"]!, style: const TextStyle(fontSize: 28)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLocked ? Colors.orange.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.12), 
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(col["status"]!, style: TextStyle(fontSize: 10, color: isLocked ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(col["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(col["count"]!, style: const TextStyle(fontSize: 12, color: Color(0xff5a5a70))),
                            ],
                          )
                        ],
                      ),
                    ),
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