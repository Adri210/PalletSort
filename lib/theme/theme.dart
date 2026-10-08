import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy950 = Color(0xFF07111F);
  static const navy900 = Color(0xFF0B1728);
  static const navy800 = Color(0xFF12243A);
  static const slate400 = Color(0xFF94A3B8);
  static const slate200 = Color(0xFFE2E8F0);
  static const cyan = Color(0xFF22D3EE);
  static const cyanDark = Color(0xFF0891B2);
  static const blue = Color(0xFF3B82F6);
  static const white = Color(0xFFF8FAFC);
  static const success = Color(0xFF34D399);
}

final ThemeData lightMode = _buildTheme(Brightness.light);
final ThemeData darkMode = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.cyan,
    brightness: brightness,
    primary: AppColors.cyanDark,
    secondary: AppColors.blue,
    surface: brightness == Brightness.dark
        ? AppColors.navy900
        : const Color(0xFFF8FAFC),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    fontFamily: 'Rubik',
    scaffoldBackgroundColor: AppColors.navy950,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.8,
        height: 1.05,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.12,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(height: 1.55),
      bodyMedium: TextStyle(height: 1.5),
      labelLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.055),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: const TextStyle(color: AppColors.slate400),
      labelStyle: const TextStyle(color: AppColors.slate200),
      prefixIconColor: AppColors.slate400,
      suffixIconColor: AppColors.slate400,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFB7185)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFB7185), width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cyan,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.cyanDark
            : Colors.transparent,
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy800,
      contentTextStyle: const TextStyle(color: AppColors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
