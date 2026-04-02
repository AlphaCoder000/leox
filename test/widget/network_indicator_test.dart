import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:leox/widgets/network_indicator.dart';
import 'package:leox/providers/connectivity_provider.dart';

import 'network_indicator_test.mocks.dart';

@GenerateMocks([ConnectivityProvider])
void main() {
  group('NetworkIndicator Widget Tests', () {
    late MockConnectivityProvider mockConnectivityProvider;

    setUp(() {
      mockConnectivityProvider = MockConnectivityProvider();
    });

    testWidgets('should show nothing when isChecking is true', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(true);
      when(mockConnectivityProvider.isConnected).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: NetworkIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('should show nothing when isConnected is true', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: NetworkIndicator(),
            ),
          ),
        ),
      );

      // Should show AnimatedContainer but no offline message
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
      expect(find.text('No Internet Connection'), findsNothing);
    });

    testWidgets('should show offline message when not connected', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: NetworkIndicator(),
            ),
          ),
        ),
      );

      // Should show the red container with offline message
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('No Internet Connection'), findsOneWidget);
    });

    testWidgets('should respond to connectivity changes', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: NetworkIndicator(),
            ),
          ),
        ),
      );

      // Initially connected - should not show offline message
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
      expect(find.text('No Internet Connection'), findsNothing);

      // Simulate disconnection
      when(mockConnectivityProvider.isConnected).thenReturn(false);
      mockConnectivityProvider.notifyListeners();
      await tester.pump();

      // Should show offline message
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('No Internet Connection'), findsOneWidget);
    });

    testWidgets('should have correct styling for offline state', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: NetworkIndicator(),
            ),
          ),
        ),
      );

      // Check icon styling
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.wifi_off));
      expect(iconWidget.color, equals(Colors.white));
      expect(iconWidget.size, equals(16));

      // Check text styling
      final textWidget = tester.widget<Text>(find.text('No Internet Connection'));
      expect(textWidget.style?.color, equals(Colors.white));
      expect(textWidget.style?.fontSize, equals(12));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w500));
    });
  });

  group('FloatingNetworkIndicator Widget Tests', () {
    late MockConnectivityProvider mockConnectivityProvider;

    setUp(() {
      mockConnectivityProvider = MockConnectivityProvider();
    });

    testWidgets('should show nothing when connected', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: FloatingNetworkIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('should show nothing when checking', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(true);
      when(mockConnectivityProvider.isConnected).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: FloatingNetworkIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('should show floating indicator when offline', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: FloatingNetworkIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Offline - Some features may not work'), findsOneWidget);
    });

    testWidgets('should have correct text and icon styling', (WidgetTester tester) async {
      when(mockConnectivityProvider.isChecking).thenReturn(false);
      when(mockConnectivityProvider.isConnected).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => mockConnectivityProvider,
          child: MaterialApp(
            home: Scaffold(
              body: FloatingNetworkIndicator(),
            ),
          ),
        ),
      );

      // Check if widgets are present
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Offline - Some features may not work'), findsOneWidget);
    });
  });
}
