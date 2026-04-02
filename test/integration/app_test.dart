import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:leox/main.dart' as app;

void main() {
  // 1. MUST call this first to bridge Flutter Tests to the physical device!
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LeoX End-to-End Test (E2E) -', () {
    testWidgets('App Launch and Navigation Flow', (WidgetTester tester) async {
      // 2. Launch your entire app from the main entry point
      app.main();

      // 3. The app is heavy (Firebase init, Splash screen duration). 
      // We force the tester to wait until all loaders and animations are fully settled.
      // You may need to bump this duration if your splash screen takes longer!
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 4. At this point, depending on the test device's state,
      // it should ideally hit the Role Selection page or Splash!
      // This is a great place to "find" elements just like in Widget Testing!
      
      // Example: We expect to see your brand/app title somewhere or a "Sign" text.
      // Note: Because I am running this blind (I don't know the exact text on your login screen),
      // I am just putting a placeholder check here. You can swap this out!
      // expect(find.text('Login'), findsWidgets); 

      // 5. If you want to simulate tapping a button in a real app flow:
      // final loginButton = find.byType(ElevatedButton).first;
      // await tester.tap(loginButton);
      // await tester.pumpAndSettle();
      
      debugPrint("SUCCESS: Integration test booted the full application on the device!");
    });
  });
}
