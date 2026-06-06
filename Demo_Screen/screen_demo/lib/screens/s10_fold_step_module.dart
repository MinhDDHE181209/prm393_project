import 'package:flutter/material.dart';

class S10FoldStepModuleScreen extends StatelessWidget {
  const S10FoldStepModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gấp Nhiều Bộ Phận (Module)")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bộ đếm linh kiện: Module đã xong 2/4 🧩", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            const Text("Tiến độ nếp gấp hiện tại:", style: TextStyle(fontSize: 12)),
            const LinearProgressIndicator(value: 0.6, color: Colors.amber),
            const SizedBox(height: 20),
            Expanded(child: Container(color: const Color(0xff0e0e14), child: const Center(child: Text("📐 [Ảnh hướng dẫn tạo ngàm gài module]")))),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Trở ra")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), 
                  onPressed: () => Navigator.pushNamed(context, '/s11'), 
                  child: const Text("🧩 Lắp ghép ngay", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}