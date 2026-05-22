import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/animated_splash_screen.dart';

// Mock asset bundle that delegates standard files to rootBundle and intercepts missing images
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png') || key.endsWith('.jpeg')) {
      final List<int> transparentPngBytes = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ];
      return ByteData.sublistView(Uint8List.fromList(transparentPngBytes));
    }
    // Delegate to rootBundle for critical framework files like AssetManifest.bin
    return rootBundle.load(key);
  }
}

void main() {
  group('AnimatedSplashScreen Widget Tests', () {
    testWidgets('should display splash screen with correct corporate structure', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: DefaultAssetBundle(
                bundle: TestAssetBundle(),
                child: AnimatedSplashScreen(
                  duration: const Duration(milliseconds: 100),
                  child: testChild,
                ),
              ),
            );
          },
        ),
      );

      // Wait for animations to initiate
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AnimatedSplashScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify the presence of text elements in their capitalized forms
      expect(find.text('BRINGS'), findsOneWidget);
      expect(find.text('LEO OPUS'), findsOneWidget);
      expect(find.text('Hiring platform along with maintenance contracts'), findsOneWidget);

      // Avoid timer leaks by settling
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    });

    testWidgets('should navigate to main screen after duration completes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testChild = Scaffold(
        body: Center(child: Text('Main App')),
      );

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: DefaultAssetBundle(
                bundle: TestAssetBundle(),
                child: AnimatedSplashScreen(
                  duration: const Duration(milliseconds: 100),
                  child: testChild,
                ),
              ),
            );
          },
        ),
      );

      // Initially, splash screen elements are visible, main app is not loaded
      expect(find.text('LEO OPUS'), findsOneWidget);
      expect(find.text('Main App'), findsNothing);

      // Pump and settle to allow animation/timer completion and navigation
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now, main app should be loaded successfully
      expect(find.text('Main App'), findsOneWidget);
      expect(find.text('LEO OPUS'), findsNothing);
    });
  });
}
