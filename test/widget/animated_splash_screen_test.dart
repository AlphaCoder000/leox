import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/animated_splash_screen.dart';

void main() {
  group('AnimatedSplashScreen Widget Tests', () {
    testWidgets('should display splash screen with correct structure', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: AnimatedSplashScreen(
                duration: const Duration(milliseconds: 100),
                child: testChild, // Short duration for testing
              ),
            );
          },
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 50));

      // Check if splash screen is displayed
      expect(find.byType(AnimatedSplashScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Check if app name is displayed
      expect(find.text('LeoOpus'), findsOneWidget);
      expect(find.text('Smart Hiring Platform'), findsOneWidget);

      // Check if loading text is displayed
      expect(find.text('Loading amazing experience...'), findsOneWidget);

      // Check if logo icon is displayed
      expect(find.byIcon(Icons.work_rounded), findsOneWidget);

      // Check if loading dots are displayed
      expect(find.byType(Container), findsWidgets); // Loading dots are containers

      // Wait for completion to avoid timer issues
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    });

    testWidgets('should have correct logo styling and animations', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: AnimatedSplashScreen(
                duration: const Duration(milliseconds: 100),
                child: testChild,
              ),
            );
          },
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 50));

      // Check if logo icon has correct properties
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.work_rounded));
      expect(iconWidget.color, equals(const Color(0xFF1976D2)));
      expect(iconWidget.size, equals(60.sp));

      // Check if app name has correct styling
      final appNameText = tester.widget<Text>(find.text('LeoOpus'));
      expect(appNameText.style?.fontSize, equals(28.sp));
      expect(appNameText.style?.fontWeight, equals(FontWeight.bold));
      expect(appNameText.style?.color, equals(Colors.white));

      // Check if tagline has correct styling
      final taglineText = tester.widget<Text>(find.text('Smart Hiring Platform'));
      expect(taglineText.style?.fontSize, equals(14.sp));
      expect(taglineText.style?.fontWeight, equals(FontWeight.w300));
      expect(taglineText.style?.color, equals(Colors.white.withOpacity(0.8)));

      // Wait for completion to avoid timer issues
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    });

    testWidgets('should display background particles', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: AnimatedSplashScreen(
                duration: const Duration(milliseconds: 100),
                child: testChild,
              ),
            );
          },
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 50));

      // Check if positioned widgets (particles) are present
      expect(find.byType(Positioned), findsWidgets);
      
      // There should be 20 particles
      final positionedWidgets = tester.widgetList<Positioned>(find.byType(Positioned));
      expect(positionedWidgets.length, equals(20));

      // Wait for completion to avoid timer issues
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    });

    testWidgets('should navigate to main screen after duration', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: AnimatedSplashScreen(
                duration: const Duration(milliseconds: 100),
                child: testChild,
              ),
            );
          },
        ),
      );

      // Initially splash screen should be visible
      expect(find.text('LeoOpus'), findsOneWidget);
      expect(find.text('Main App'), findsNothing);

      // Wait for navigation to happen
      await tester.pumpAndSettle(const Duration(milliseconds: 150));

      // After duration, main app should be visible
      expect(find.text('Main App'), findsOneWidget);
      expect(find.text('LeoOpus'), findsNothing);
    });

    testWidgets('should have proper gradient background', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: AnimatedSplashScreen(
                duration: const Duration(milliseconds: 100),
                child: testChild,
              ),
            );
          },
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 50));

      // Check if container with gradient decoration is present
      final containers = tester.widgetList<Container>(find.byType(Container));
      final gradientContainer = containers.firstWhere(
        (container) => container.decoration is BoxDecoration,
        orElse: () => throw Exception('No gradient container found'),
      );

      final decoration = gradientContainer.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());

      // Wait for completion to avoid timer issues
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    });

    testWidgets('should have correct text content', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: AnimatedSplashScreen(
                duration: const Duration(milliseconds: 100),
                child: testChild,
              ),
            );
          },
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 50));

      // Check all text elements are present
      expect(find.text('LeoOpus'), findsOneWidget);
      expect(find.text('Smart Hiring Platform'), findsOneWidget);
      expect(find.text('Loading amazing experience...'), findsOneWidget);

      // Check loading text styling
      final loadingText = tester.widget<Text>(find.text('Loading amazing experience...'));
      expect(loadingText.style?.fontSize, equals(11.sp));
      expect(loadingText.style?.fontWeight, equals(FontWeight.w300));
      expect(loadingText.style?.color, equals(Colors.white.withOpacity(0.7)));

      // Wait for completion to avoid timer issues
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    });
  });
}
