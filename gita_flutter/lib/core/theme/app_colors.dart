import 'package:flutter/material.dart';

/// App color palette - ported from Kotlin implementation
class AppColors {
  // Primary Colors (Blue)
  static const Color primary = Color(0xFF0599F3);
  static const Color primaryShade1 = Color(0xFF8493DA);
  static const Color primaryShade2 = Color(0xFF567B9D);
  static const Color saffron = primary; // Alias for backward compatibility if needed, or remove if safe

  // Secondary Colors (Warm/Orange)
  static const Color secondary = Color(0xFFB36C3A);
  
  // Tertiary Colors (Green)
  static const Color tertiary = Color(0xFF407961);

  static const Color sacredGold = Color(0xFFFFD700); // Keeping as it seems semantic
  
  // Neutral/Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAF9F6);
  static const Color lightSaffron = primaryShade1; // Mapping to new shade
  static const Color darkPurple = Color(0xFF311B92); // Keep or map to new palette? Leaving for now.
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color gray900 = Color(0xFF212121);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray100 = Color(0xFFF5F5F5);
  
  // Background Colors for Light Theme
  static const Color lightBackground = white;
  static const Color lightSurface = offWhite;
  static const Color lightOnBackground = gray900;
  static const Color lightOnSurface = gray900;
  
  // Background Colors for Dark Theme
  static const Color darkBackground = gray900;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = offWhite;
  static const Color darkOnSurface = offWhite;
}
