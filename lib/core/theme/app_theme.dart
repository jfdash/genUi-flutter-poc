import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFFAF9F6);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF3F1EC);
  static const Color border = Color(0xFFE8E4DC);
  static const Color textPrimary = Color(0xFF101010);
  static const Color textSecondary = Color(0xFF6C6A65);
  static const Color textTertiary = Color(0xFF9B978F);
  static const Color accent = Color(0xFFF4C8A6);
  static const Color accentSoft = Color(0xFFF8E5D6);
  static const Color action = Color(0xFF0E0E0E);
  static const Color success = Color(0xFF2E7D32);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: action,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        error: Color(0xFFB3261E),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 0.95,
        ),
        displayMedium: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.0,
        ),
        headlineLarge: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.05,
        ),
        headlineMedium: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 1.2,
        ),
      ).apply(fontFamily: 'Inter'),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textTertiary, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: textPrimary, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: action,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      dividerColor: border,
    );
  }
}
