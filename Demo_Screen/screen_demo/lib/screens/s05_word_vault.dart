import 'package:flutter/material.dart';

class S05WordVaultScreen extends StatelessWidget {
  const S05WordVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final words = [
      {"kanji": "山折り", "romaji": "Yamaori", "meaning": "Gấp nếp núi (Lồi)"},
      {"kanji": "谷折り", "romaji": "Taniori", "meaning": "Gấp nếp thung lũng (Lõm)"},
      {"kanji": "鶴", "romaji": "Tsuru", "meaning": "Con chim hạc"},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sổ Từ Vựng Local SQLite 📖", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(decoration: InputDecoration(hintText: "Tìm kiếm từ nhanh...", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xff0e0e14))),
              const SizedBox(height: 14),
              Row(
                children: [
                  FilterChip(label: const Text("Tất cả"), selected: true, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text("Cần ôn tập"), selected: false, onSelected: (_) {}),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, idx) => Card(
                    color: const Color(0xff0e0e14),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: IconButton(icon: const Icon(Icons.volume_up_rounded, color: Color(0xff1ebd59)), onPressed: () {}),
                      title: Text("${words[idx]["kanji"]} | ${words[idx]["romaji"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(words[idx]["meaning"]!),
                      trailing: const Icon(Icons.star, color: Colors.amber),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff8652f4),
        icon: const Icon(Icons.quiz, color: Colors.white),
        label: const Text("Ôn tập nhanh (Quiz)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.pushNamed(context, '/s12'),
      ),
    );
  }
}