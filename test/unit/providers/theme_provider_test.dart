import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leox/providers/theme_povider.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('should initialize with system theme mode', () {
      expect(themeProvider.themeMode, ThemeMode.system);
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

    test('should set system theme mode', () {
      themeProvider.setSystem();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('should toggle theme correctly', () {
      // Start with system
      expect(themeProvider.themeMode, ThemeMode.system);
      
      // Toggle to dark
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDark, true);
      
      // Toggle to light
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.isDark, false);
      
      // Toggle back to system
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('should set theme mode directly', () {
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      
      themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('should notify listeners when theme changes', () {
      var notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      themeProvider.setLight();
      expect(notified, true);
    });

    test('should handle isDark getter correctly', () {
      themeProvider.setLight();
      expect(themeProvider.isDark, false);
      
      themeProvider.setDark();
      expect(themeProvider.isDark, true);
      
      themeProvider.setSystem();
      // System theme depends on platform, so we just check it doesn't crash
      expect(themeProvider.themeMode, ThemeMode.system);
    });
  });
}
