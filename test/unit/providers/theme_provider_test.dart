import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leox/providers/theme_povider.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('should initialize with light theme mode', () {
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    test('should set light theme mode', () {
      themeProvider.setLight();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDark, false);
    });

    test('should set dark theme mode', () {
      themeProvider.setDark();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDark, true);
    });

    test('should toggle theme correctly', () {
      // Start with light
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Toggle to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDark, true);
      
      // Toggle to light
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDark, false);
    });

    test('should set theme mode directly', () {
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Setting to system should fallback to light
      themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    test('should notify listeners when theme changes', () {
      var notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      themeProvider.setDark();
      expect(notified, true);
    });

    test('should handle isDark getter correctly', () {
      themeProvider.setLight();
      expect(themeProvider.isDark, false);
      
      themeProvider.setDark();
      expect(themeProvider.isDark, true);
    });
  });
}
