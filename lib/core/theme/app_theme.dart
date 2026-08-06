import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFF4A340);
  static const Color primaryLight = Color(0xFFF7BB70);
  static const Color primaryDark = Color(0xFFCF8020);
  static const Color accent = Color(0xFF3B5FE0);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color card = Color(0xFF242424);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color divider = Color(0xFF3A3A3A);

  static const Color pending = Color(0xFFFF9800);
  static const Color completed = Color(0xFF3FAE6A);
  static const Color cancelled = Color(0xFFDC3939);

  static ThemeData get lightTheme => theme; // same theme use hoga dono jagah

  static ThemeData get darkTheme => theme;

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        decoration: TextDecoration.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}