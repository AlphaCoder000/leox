import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void setLight() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void setDark() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setDark();
    } else {
      setLight();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      // Fallback to light if system is passed accidentally
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = mode;
    }
    notifyListeners();
  }
}
