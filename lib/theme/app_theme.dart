import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2E5077);

  // Background colors
  static const Color background = Color(0xFFF8F9FC);
  static const Color cardBackground = Colors.white;
  static const Color mintBackground = Color(0xFFE8F5F0);

  // Gradient colors for cards
  static const Color healthGradientStart = Color(0xFF7C3AED);
  static const Color healthGradientEnd = Color(0xFF9F7AEA);

  static const Color policyGradientStart = Color(0xFFF472B6);
  static const Color policyGradientEnd = Color(0xFFFDA4AF);

  static const Color infoGradientStart = Color(0xFFA78BFA);
  static const Color infoGradientEnd = Color(0xFFC4B5FD);

  static const Color renewGradientStart = Color(0xFF1E3A5F);
  static const Color renewGradientEnd = Color(0xFF3B5998);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Icon background colors
  static const Color motorIconBg = Color(0xFFDCFCE7);
  static const Color healthIconBg = Color(0xFFE0E7FF);
  static const Color travelIconBg = Color(0xFFFEF3C7);
  static const Color medicalIconBg = Color(0xFFFFE4E6);
}

class AppGradients {
  static const LinearGradient health = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.healthGradientStart, AppColors.healthGradientEnd],
  );

  static const LinearGradient policy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.policyGradientStart, AppColors.policyGradientEnd],
  );

  static const LinearGradient info = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.infoGradientStart, AppColors.infoGradientEnd],
  );

  static const LinearGradient renew = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.renewGradientStart, AppColors.renewGradientEnd],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
