import 'package:flutter/material.dart';

/// App color palette - ported from Kotlin implementation
class AppColors {
  // Primary Colors
  static const Color saffron = Color(0xFFFF9933);
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color sacredGold = Color(0xFFFFD700);
  
  // Secondary Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAF9F6);
  static const Color lightSaffron = Color(0xFFFFE5B4);
  static const Color darkPurple = Color(0xFF311B92);
  
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
