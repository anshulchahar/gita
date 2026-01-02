import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration - Material 3
class AppTheme {
  /// Light theme color scheme
  static ColorScheme get lightColorScheme => ColorScheme.light(
    primary: AppColors.saffron,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.lightSaffron,
    onPrimaryContainer: AppColors.deepPurple,
    
    secondary: AppColors.deepPurple,
    onSecondary: AppColors.white,
    secondaryContainer: const Color(0xFFE1BEE7),
    onSecondaryContainer: AppColors.darkPurple,
    
    tertiary: AppColors.sacredGold,
    onTertiary: AppColors.gray900,
    
    error: AppColors.error,
    onError: AppColors.white,
    
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    
    surfaceContainerHighest: AppColors.gray100,
    onSurfaceVariant: AppColors.gray700,
    
    outline: AppColors.gray300,
    outlineVariant: AppColors.gray100,
  );

  /// Dark theme color scheme
  static ColorScheme get darkColorScheme => ColorScheme.dark(
    primary: AppColors.saffron,
    onPrimary: AppColors.gray900,
    primaryContainer: const Color(0xFFCC7A29),
    onPrimaryContainer: AppColors.white,
    
    secondary: const Color(0xFF9C27B0),
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.darkPurple,
    onSecondaryContainer: const Color(0xFFE1BEE7),
    
    tertiary: AppColors.sacredGold,
    onTertiary: AppColors.gray900,
    
    error: const Color(0xFFCF6679),
    onError: AppColors.gray900,
    
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    
    surfaceContainerHighest: const Color(0xFF2C2C2C),
    onSurfaceVariant: AppColors.gray300,
    
    outline: AppColors.gray700,
    outlineVariant: const Color(0xFF3C3C3C),
  );

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightOnSurface,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColors.gray100,
    ),
  );

  /// Dark theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
  );
}

/// Spacing constants
class Spacing {
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
}
