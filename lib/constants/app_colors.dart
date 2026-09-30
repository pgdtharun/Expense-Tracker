import 'package:flutter/material.dart';

/// Central palette so light/dark themes stay consistent and colors aren't
/// hardcoded across widgets.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4C6EF5);
  static const Color primaryDark = Color(0xFF7C9AFF);

  static const Color success = Color(0xFF2F9E44);
  static const Color danger = Color(0xFFE03131);

  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color darkBackground = Color(0xFF121317);
  static const Color darkSurface = Color(0xFF1E1F24);
}
