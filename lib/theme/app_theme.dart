import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF10B981); // Emerald
  static const Color primaryDarkGreen = Color(0xFF047857);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);

  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF162032);
  static const Color borderDark = Color(0xFF334155);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentCyan,
      surface: cardLight,
      error: dangerRed,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentCyan,
      surface: cardDark,
      error: dangerRed,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );
}
