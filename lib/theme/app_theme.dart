import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF11D469);

  // Background Colors
  static const Color backgroundLight = Color(0xFFEAF9E7); // Used in Light Mode
  static const Color backgroundDark = Color(0xFF102218); // Used in Dark Mode

  // Bottom Navigation & Cards
  static const Color navBackground = Color(0xFF013237);
  static const Color cardGlass = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)
  static const Color cardGlassDark = Color(
    0x331E293B,
  ); // Dark slate 800 with opacity

  // Status Colors
  static const Color statusWarning = Color(0xFFF97316); // Orange 500
  static const Color statusDanger = Color(0xFFEF4444); // Red 500

  // Optional global theme data (You can expand this later)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Inter',
    );
  }
}
