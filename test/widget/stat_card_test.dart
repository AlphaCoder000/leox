import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/stat_card.dart';

void main() {
  group('StatCard Widget Tests', () {
    testWidgets('should display all required properties correctly', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const testTitle = 'Test Title';
      const testValue = 42;
      const testSubtitle = 'Test subtitle description';
      const testIcon = Icons.work;

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: testTitle,
                  value: testValue,
                  subtitle: testSubtitle,
                  icon: testIcon,
                ),
              ),
            );
          },
        ),
      );

      // Check if the widget is rendered
      expect(find.byType(StatCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // Check if the icon is displayed
      expect(find.byIcon(testIcon), findsOneWidget);

      // Check if the text elements are displayed
      expect(find.text(testValue.toString()), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });

    testWidgets('should handle long text with ellipsis', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      const longTitle = 'This is a very long title that should be truncated';
      const longSubtitle = 'This is a very long subtitle that should also be truncated with ellipsis';

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: longTitle,
                  value: 100,
                  subtitle: longSubtitle,
                  icon: Icons.star,
                ),
              ),
            );
          },
        ),
      );

      // Check that text is rendered (even if truncated)
      expect(find.byType(Text), findsWidgets);
      
      // Check for overflow behavior - should not overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display zero value correctly', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: 'Zero Test',
                  value: 0,
                  subtitle: 'Zero value test',
                  icon: Icons.exposure_zero,
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('Zero Test'), findsOneWidget);
      expect(find.text('Zero value test'), findsOneWidget);
    });

    testWidgets('should handle negative values', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: 'Negative Test',
                  value: -5,
                  subtitle: 'Negative value test',
                  icon: Icons.remove,
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('should have correct card styling', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: 'Style Test',
                  value: 1,
                  subtitle: 'Testing card styling',
                  icon: Icons.style,
                ),
              ),
            );
          },
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.elevation, equals(3.0));
      expect(cardWidget.shape, isA<RoundedRectangleBorder>());
      
      final roundedRectBorder = cardWidget.shape as RoundedRectangleBorder;
      expect(roundedRectBorder.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('should have fixed height container', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: 'Height Test',
                  value: 1,
                  subtitle: 'Testing fixed height',
                  icon: Icons.height,
                ),
              ),
            );
          },
        ),
      );

      // Find the SizedBox that has the fixed height (there might be multiple SizedBox widgets)
      final sizedBoxWidgets = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final fixedHeightSizedBox = sizedBoxWidgets.firstWhere(
        (sizedBox) => sizedBox.height == 22.h,
        orElse: () => throw Exception('SizedBox with fixed height not found'),
      );
      expect(fixedHeightSizedBox.height, equals(22.h));
    });

    testWidgets('should use correct text styles', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: StatCard(
                  title: 'Style Test',
                  value: 123,
                  subtitle: 'Testing text styles',
                  icon: Icons.text_fields,
                ),
              ),
            );
          },
        ),
      );

      // Find all text widgets
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      
      // Should have 3 text widgets: value, title, subtitle
      expect(textWidgets.length, equals(3));
      
      // Check value text style (should be bold)
      final valueText = textWidgets.firstWhere(
        (text) => text.data == '123',
        orElse: () => throw Exception('Value text not found'),
      );
      expect(valueText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should handle different icons correctly', (WidgetTester tester) async {
      const icons = [
        Icons.work,
        Icons.home,
        Icons.settings,
        Icons.person,
        Icons.email,
      ];

      for (final icon in icons) {
        // Initialize Sizer for testing
        tester.binding.window.physicalSizeTestValue = const Size(411, 823);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                home: Scaffold(
                  body: StatCard(
                    title: 'Icon Test',
                    value: 1,
                    subtitle: 'Testing $icon',
                    icon: icon,
                  ),
                ),
              );
            },
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
        await tester.pumpWidget(Container()); // Clean up
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      }
    });

    testWidgets('should be responsive to theme changes', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.binding.window.physicalSizeTestValue = const Size(411, 823);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
              home: Scaffold(
                body: StatCard(
                  title: 'Theme Test',
                  value: 1,
                  subtitle: 'Testing theme',
                  icon: Icons.palette,
                ),
              ),
            );
          },
        ),
      );

      // Should render without errors with custom theme
      expect(find.byType(StatCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
