import 'package:flutter/material.dart';

class S11AssemblyGuideScreen extends StatelessWidget {
  const S11AssemblyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hướng Dẫn Ráp Nối Khối 🔧")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Bước ráp: 1/3", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Expanded(child: Container(width: double.infinity, color: const Color(0xff0e0e14), child: const Center(child: Text("🎬 [Video/GIF hướng dẫn đút ngàm giấy chốt vào nhau]")))),
            const SizedBox(height: 20),
            const Text("Chỉ dẫn: Đút ngàm A của module 1 vào khe hở B của module 2 theo chiều mũi tên.", textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1ebd59), minimumSize: const Size.fromHeight(50)),
              onPressed: () => Navigator.pushNamed(context, '/s12'),
              child: const Text("Hoàn Thành Sản Phẩm 🎉", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}