import 'package:flutter/material.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4A017);
  static const Color darkNavy = Color(0xFF0A1628);
  static const Color deepBlue = Color(0xFF0D2137);
  static const Color midBlue = Color(0xFF0A1F3D);
  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color skyBlue = Color(0xFF90CAF9);
  static const Color warningOrange = Color(0xFFFF8C00);
  static const Color dangerRed = Color(0xFFB71C1C);
  static const Color lightText = Color(0xFFCCE4FF);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkNavy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ).copyWith(surface: darkNavy),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(fontFamily: 'Georgia', color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: lightText),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: lightText),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: darkNavy,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  static Color qualityColor(String quality) => switch (quality) {
        'optimal' => forestGreen,
        'acceptable' => skyBlue,
        'poor' => warningOrange,
        'catastrophic' => dangerRed,
        _ => Colors.grey,
      };
}
