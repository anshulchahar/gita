import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration - Material 3
class AppTheme {
  /// Light theme color scheme
  static ColorScheme get lightColorScheme => ColorScheme.light(
    // Primary color - Blue (matching splash screen)
    primary: AppColors.primary, 
    onPrimary: AppColors.white,
    primaryContainer: AppColors.white, // White background for containers
    onPrimaryContainer: AppColors.gray900,
    
    // 30% - Secondary/Structure (Orange)
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.gray100, // Light gray for secondary containers
    onSecondaryContainer: AppColors.gray900,
    
    // 60% - Dominant/Background (Blue)
    surface: AppColors.white, // White surface
    onSurface: AppColors.gray900,
    
    error: AppColors.error,
    onError: AppColors.white,
    
    // Background is handled by Scaffold in ThemeData, but setting these for completeness
    surfaceContainerHighest: AppColors.gray100, // Light gray for variants
    onSurfaceVariant: AppColors.gray700,
    
    outline: AppColors.gray300,
    outlineVariant: AppColors.gray200,
  );

  /// Dark theme color scheme - reusing same vibrant palette for consistency
  static ColorScheme get darkColorScheme => lightColorScheme;

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    
    // Pure white background for all pages (splash screen has its own)
    scaffoldBackgroundColor: AppColors.white, 
    
    // App Bar with secondary color
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    
    cardTheme: const CardThemeData(
      color: AppColors.secondary,
      elevation: 4,
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.secondary,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.white.withOpacity(0.7),
    ),
    
    // Accent CTA (Green)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gray900,
        side: const BorderSide(color: AppColors.gray300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      filled: true,
      fillColor: AppColors.gray100,
      hintStyle: TextStyle(color: AppColors.gray500),
      labelStyle: const TextStyle(color: AppColors.gray700),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.gray900),
      bodyMedium: TextStyle(color: AppColors.gray900),
      titleLarge: TextStyle(color: AppColors.gray900),
      titleMedium: TextStyle(color: AppColors.gray900),
      titleSmall: TextStyle(color: AppColors.gray900),
    ),
    
    iconTheme: const IconThemeData(color: AppColors.gray900),
  );

  /// Dark theme - same as light for this specific design request
  static ThemeData get darkTheme => lightTheme;
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
