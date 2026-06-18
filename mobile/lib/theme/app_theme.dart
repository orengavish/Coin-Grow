import 'package:flutter/material.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4A017);
  static const Color darkBrown = Color(0xFF3E2004);
  static const Color parchment = Color(0xFFF5E6C8);
  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color skyBlue = Color(0xFF90CAF9);
  static const Color warningOrange = Color(0xFFFF8C00);
  static const Color dangerRed = Color(0xFFB71C1C);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'Georgia'),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: darkBrown,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  // Quality color for choice buttons
  static Color qualityColor(String quality) => switch (quality) {
        'optimal' => forestGreen,
        'acceptable' => skyBlue,
        'poor' => warningOrange,
        'catastrophic' => dangerRed,
        _ => Colors.grey,
      };
}
