import 'package:flutter/material.dart';
import 's03_home.dart';
import 's04_profile.dart';
import 's05_word_vault.dart';

class MainTabWrapper extends StatefulWidget {
  const MainTabWrapper({super.key});

  @override
  State<MainTabWrapper> createState() => _MainTabWrapperState();
}

class _MainTabWrapperState extends State<MainTabWrapper> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const S03HomeScreen(),
    const S04ProfileScreen(),
    const S05WordVaultScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xff0e0e14),
        selectedItemColor: const Color(0xff1ebd59), // Màu lá cây đặc tả nhóm Tab
        unselectedItemColor: const Color(0xff5a5a70),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Khám Phá"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: "Tiến Trình"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: "Sổ Từ Vựng"),
        ],
      ),
    );
  }
}