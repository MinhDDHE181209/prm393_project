import 'package:flutter/material.dart';

class S07ModelDetailScreen extends StatelessWidget {
  const S07ModelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu cấu hình mẫu gấp được truyền từ màn hình S06 sang
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {
      "name": "Mẫu Mặc Định",
      "jp": "おりがみ",
      "isModule": false
    };

    final String name = args["name"].toString();
    final String jp = args["jp"].toString();
    final bool isModule = args["isModule"] as bool;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, 
              width: double.infinity, 
              decoration: BoxDecoration(color: const Color(0xff0e0e14), borderRadius: BorderRadius.circular(14)), 
              child: Center(
                child: Text(
                  isModule ? "🧩 [Ảnh mô phỏng khối ráp Module]" : "Swan [Ảnh mô phỏng 3D hình đơn]", 
                  style: const TextStyle(color: Colors.grey)
                )
              )
            ),
            const SizedBox(height: 20),
            Text("$name ($jp)", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18), 
                Text(isModule ? " Thể loại: Gấp nhiều Module ráp nối" : " Thể loại: Gấp từng bước định đích")
              ],
            ),
            const Divider(height: 30, color: Color(0xff202030)),
            const Text("Từ vựng JP xem trước trong bài:", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("• 山折り (Yamaori): Gấp nếp núi\n• 谷折り (Taniori): Gấp nếp thung lũng", style: TextStyle(color: Colors.grey, height: 1.5)),
            const SizedBox(height: 20),
            const Text("Chọn màu hoa văn giấy phù hợp:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Row(
              children: [
                CircleAvatar(backgroundColor: Colors.red, radius: 16), SizedBox(width: 8),
                CircleAvatar(backgroundColor: Colors.blue, radius: 16), SizedBox(width: 8),
                CircleAvatar(backgroundColor: Colors.amber, radius: 16),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isModule ? const Color(0xffe59600) : const Color(0xff1ebd59), 
                minimumSize: const Size.fromHeight(52), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () {
                // ĐIỀU HƯỚNG THÔNG MINH DỰA TRÊN THỂ LOẠI HÌNH GẤP
                if (isModule) {
                  // Nếu là hình modul, chuyển tới S10
                  Navigator.pushNamed(context, '/s10');
                } else {
                  // Nếu là hình đơn lẻ, chuyển tới S09
                  Navigator.pushNamed(context, '/s09');
                }
              },
              child: Text(
                isModule ? "Bắt Đầu Gấp Module 🧩" : "Bắt Đầu Gấp Từng Bước 🎯", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }
}