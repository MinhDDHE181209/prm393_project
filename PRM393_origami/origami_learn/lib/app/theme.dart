import 'package:flutter/material.dart';

/// Theme tối cho OrigamiLearn — màu chủ đạo Amber (giấy gấp) + Teal (Nhật Bản).
class AppTheme {
  static const Color amber = Color(0xFFC07000);
  static const Color teal = Color(0xFF00796B);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1F1F1F);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: amber,
      colorScheme: const ColorScheme.dark(
        primary: amber,
        secondary: teal,
        surface: surface,
        // 'background' đã deprecated trong ColorScheme từ Flutter 3.22+,
        // 'surface' đảm nhiệm luôn vai trò màu nền mặc định.
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amber,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
