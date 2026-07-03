import 'package:flutter/material.dart';

class AppColors {
  static const bgPrimary = Color(0xFF050B16);
  static const bgSecondary = Color(0xFF171F2C);
  static const bgTertiary = Color(0xFF252E3C);
  static const strokePrimary = Color(0xFF36D1FF);
  static const strokeSecondary = Color(0xFF3C4658);
  static const textPrimary = Color(0xFFF3F8FF);
  static const textSecondary = Color(0xFFBBC4D3);
  static const textMuted = Color(0xFF768092);
  static const cyanSoft = Color(0xFF4DD7FF);
  static const cyanStart = Color(0xFF349CC9);
  static const cyanEnd = Color(0xFF4FCDF1);
  static const buttonTextDark = Color(0xFF0C2032);
  static const greenOk = Color(0xFF49C45A);
  static const yellowWarn = Color(0xFFE0B423);
  static const redError = Color(0xFFED4337);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyanSoft,
        secondary: AppColors.cyanEnd,
        surface: AppColors.bgSecondary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.strokeSecondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.strokeSecondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.strokePrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
