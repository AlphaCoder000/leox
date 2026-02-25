import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:leox/main.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/providers/connectivity_provider.dart';
import 'package:leox/views/splash_view.dart';

void main() {
  group('LeoX App Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen should be displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify splash screen is shown
      expect(find.byType(SplashView), findsOneWidget);
    });

    testWidgets('Theme provider should toggle theme', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      // Test initial theme
      expect(themeProvider.themeMode, ThemeMode.system);

      // Test theme toggle
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);

      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    testWidgets('Connectivity provider should initialize', (WidgetTester tester) async {
      final connectivityProvider = ConnectivityProvider();
      
      // Test initial state
      expect(connectivityProvider.isChecking, false);
      expect(connectivityProvider.connectionStatus, 'Unknown');
    });
  });

  group('Provider Tests', () {
    test('ThemeProvider should work correctly', () {
      final themeProvider = ThemeProvider();
      
      // Test initial state
      expect(themeProvider.themeMode, ThemeMode.system);
      
      // Test isDark getter
      final isDark = themeProvider.isDark;
      expect(isDark, isA<bool>());
    });

    test('ConnectivityProvider should handle state changes', () {
      final connectivityProvider = ConnectivityProvider();
      
      // Test initial state
      expect(connectivityProvider.isConnected, true);
      expect(connectivityProvider.isChecking, false);
      expect(connectivityProvider.connectionStatus, 'Unknown');
    });
  });
}
