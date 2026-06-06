import 'package:flutter/material.dart';

class S09FoldStepTargetScreen extends StatelessWidget {
  const S09FoldStepTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Luồng Gấp Định Đích (Bước 3/12)")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const LinearProgressIndicator(value: 0.25, color: Colors.red),
            const SizedBox(height: 20),
            Expanded(child: Container(decoration: BoxDecoration(color: const Color(0xff0e0e14), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text("🖼️ [GIF/Hình ảnh động hướng dẫn nếp gấp]", style: TextStyle(color: Colors.grey))))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  title: const Text("Từ vựng: 山折り (Yamaori)"),
                  content: const Text("Bạn có muốn lưu từ này vào Sổ Từ Vựng SQLite không?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")),
                    ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⭐ Đã lưu thành công vào SQLite S05!"))); }, child: const Text("Lưu ngay")),
                  ],
                ));
              },
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                  children: [
                    TextSpan(text: "Hướng dẫn: Thực hiện nếp gấp "),
                    TextSpan(text: "山折り (Yamaori)", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    TextSpan(text: " dọc theo đường kẻ chấm giữa tờ giấy."),
                  ]
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Quay lại")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4083ff)), 
                  onPressed: () => Navigator.pushNamed(context, '/s12'), 
                  child: const Text("Xác nhận nếp gấp ✓", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}