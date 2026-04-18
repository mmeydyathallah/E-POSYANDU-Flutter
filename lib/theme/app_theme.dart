import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF11D469);

  // Background Colors
  static const Color backgroundLight = Color(0xFFEAF9E7); // Used in Light Mode
  static const Color backgroundDark = Color(0xFF101214); // Used in Dark Mode

  // Bottom Navigation & Cards
  static const Color navBackground = Color(0xFF013237);
  static const Color cardGlass = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)
  static const Color cardGlassDark = Color(
    0x331E293B,
  ); // Dark slate 800 with opacity

  // Status Colors
  static const Color statusWarning = Color(0xFFF97316); // Orange 500
  static const Color statusDanger = Color(0xFFEF4444); // Red 500

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A1D21) : Colors.white;

  static Color surfaceMuted(BuildContext context) => isDark(context)
      ? const Color(0xFF20242A)
      : Colors.white.withValues(alpha: 0.72);

  static Color surfaceStrong(BuildContext context) =>
      isDark(context) ? const Color(0xFF0D0F12) : navBackground;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF2FFF6) : Colors.black87;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? const Color(0xFFB3BAC5) : Colors.black54;

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? const Color(0xFF818A96) : Colors.black38;

  static Color border(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);

  static Color shadow(BuildContext context) => isDark(context)
      ? Colors.black.withValues(alpha: 0.26)
      : Colors.black.withValues(alpha: 0.05);

  // Optional global theme data (You can expand this later)
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.82),
        ),
        elevation: const WidgetStatePropertyAll(0),
        side: WidgetStatePropertyAll(
          BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(color: Colors.black87),
        ),
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(color: Colors.black38),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.72),
        selectedColor: primary.withValues(alpha: 0.18),
        disabledColor: Colors.grey.shade200,
        secondarySelectedColor: primary.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: Colors.black87),
        secondaryLabelStyle: const TextStyle(color: primary),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF2FFF6),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1D21),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF20242A),
        labelStyle: const TextStyle(color: Color(0xFFB3BAC5)),
        hintStyle: const TextStyle(color: Color(0xFF818A96)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: const WidgetStatePropertyAll(Color(0xFF20242A)),
        elevation: const WidgetStatePropertyAll(0),
        side: WidgetStatePropertyAll(
          BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(color: Color(0xFFF2FFF6)),
        ),
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(color: Color(0xFF818A96)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF20242A),
        selectedColor: primary.withValues(alpha: 0.18),
        disabledColor: const Color(0xFF20242A),
        secondarySelectedColor: primary.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: Color(0xFFF2FFF6)),
        secondaryLabelStyle: const TextStyle(color: primary),
        brightness: Brightness.dark,
      ),
    );
  }
}
