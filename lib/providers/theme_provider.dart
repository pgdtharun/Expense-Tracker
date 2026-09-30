import 'package:flutter/material.dart';

/// Holds the app's light/dark mode preference.
///
/// Kept intentionally simple (in-memory only) — persisting the choice with
/// shared_preferences would be a natural next step but isn't required for
/// this task.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
