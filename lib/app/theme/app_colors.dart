// lib/app/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Defines the color palette for the app.
class AppColors {
  // DARK THEME (for Login, etc.)
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color backgroundStart = Color(0xFF000000);
  static const Color backgroundEnd = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF2C2C2C);
  static const Color fontPrimary = Colors.white;
  static const Color fontSecondary = Color(0xFFB0B0B0);
  static const Color inactiveTab = Color(0xFF424242);
  static const Color textFieldBorder = Color(0xFF515151);

  // LIGHT THEME (for Home Screen)
  static const Color lightScaffoldBackground = Color(0xFFF5F5F5);
  static const Color lightCard = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color errorRed = Color.fromARGB(255, 236, 41, 41);

  static const Color accentBlue = Color(0xFF2196F3);
  static const Color botBubble = Color(0xFFE8F5E9);
  static const Color userBubble = Color(0xFF2196F3);
}