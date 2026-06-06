import 'package:flutter/material.dart';

class S06CollectionDetailScreen extends StatelessWidget {
  const S06CollectionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Phân loại rạch ròi: Hình nào đơn lẻ, hình nào dùng module
    final List<Map<String, dynamic>> items = [
      {
        "name": "Hạc Giấy Truyền Thống", 
        "jp": "折り鶴", 
        "difficulty": 2, 
        "type": "🎯 Gấp từng bước (Định đích)",
        "isModule": false // Gấp từ 1 tờ giấy duy nhất
      },
      {
        "name": "Quả Cầu Hoa Đa Khối", 
        "jp": "くす玉", 
        "difficulty": 4, 
        "type": "🧩 Gấp lắp ghép (Module)",
        "isModule": true // Gấp nhiều mảnh rồi ghép lại
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Chủ Đề Loài Chim & Hoa 🐦🌸"), backgroundColor: const Color(0xff0e0e14)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Danh Sách Mẫu Gấp Trong Bộ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  mainAxisSpacing: 14, 
                  crossAxisSpacing: 14, 
                  childAspectRatio: 0.9
                ),
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  final String itemType = items[idx]["type"].toString();
                  final String itemName = items[idx]["name"].toString();
                  final String itemJp = items[idx]["jp"].toString();
                  final int difficulty = items[idx]["difficulty"] as int;
                  final bool isModule = items[idx]["isModule"] as bool;

                  return InkWell(
                    onTap: () {
                      // Gửi kèm thông tin phân loại sang màn hình S07
                      Navigator.pushNamed(
                        context, 
                        '/s07', 
                        arguments: {"name": itemName, "jp": itemJp, "isModule": isModule}
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xff0e0e14), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xff202030))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: !isModule ? Colors.red.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1), 
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              itemType, 
                              style: TextStyle(fontSize: 10, color: !isModule ? Colors.red : Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(itemJp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Row(children: List.generate(difficulty, (index) => const Icon(Icons.star, size: 14, color: Colors.amber)))
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}