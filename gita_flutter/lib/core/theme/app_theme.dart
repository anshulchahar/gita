import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration - Material 3
class AppTheme {
  /// Light theme color scheme
  static ColorScheme get lightColorScheme => ColorScheme.light(
    // 10% - Accent/CTA (Green)
    primary: AppColors.tertiary, 
    onPrimary: AppColors.white,
    primaryContainer: AppColors.tertiary, // Ensure containers are also green if used
    onPrimaryContainer: AppColors.white,
    
    // 30% - Secondary/Structure (Orange)
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.white,
    
    // 60% - Dominant/Background (Blue)
    surface: AppColors.secondary, // Cards/Surfaces are Orange (30%)
    onSurface: AppColors.white,
    
    error: AppColors.error,
    onError: AppColors.white,
    
    // Background is handled by Scaffold in ThemeData, but setting these for completeness
    surfaceContainerHighest: AppColors.primaryShade2, // Muted blue for variants
    onSurfaceVariant: AppColors.white,
    
    outline: AppColors.white.withOpacity(0.5),
    outlineVariant: AppColors.white.withOpacity(0.2),
  );

  /// Dark theme color scheme - reusing same vibrant palette for consistency
  static ColorScheme get darkColorScheme => lightColorScheme;

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    
    // 60% - Dominant Background (Blue)
    scaffoldBackgroundColor: AppColors.primary, 
    
    // 30% - Secondary Structure (Orange)
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
    
    // 10% - Accent CTA (Green)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tertiary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: AppColors.white.withOpacity(0.1), // Translucent white on blue background
      hintStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
      labelStyle: const TextStyle(color: AppColors.white),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.white),
      titleLarge: TextStyle(color: AppColors.white),
      titleMedium: TextStyle(color: AppColors.white),
      titleSmall: TextStyle(color: AppColors.white),
    ),
    
    iconTheme: const IconThemeData(color: AppColors.white),
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
