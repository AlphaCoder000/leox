import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/maintenance_contracts/controllers/mc_provider_auth_controller.dart';
import 'package:leox/maintenance_contracts/models/mc_provider_model.dart';
import 'package:leox/maintenance_contracts/views/auth/mc_provider_login_view.dart';

class FakeMcProviderAuthController extends ChangeNotifier implements McProviderAuthController {
  bool _isLoading = false;
  String? loginResponseError;
  bool didCallSignInWithGoogle = false;

  @override
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  @override
  McProviderModel? get currentProvider => null;

  @override
  Future<void> fetchProviderProfile(String uid) async {}

  @override
  Future<String?> loginWithEmail(String email, String password) async {
    return loginResponseError;
  }

  @override
  Future<String?> registerWithEmail(
      String email, String password, String companyName, String phone, String location) async {
    return null;
  }

  @override
  Future<String?> signInWithGoogle() async {
    didCallSignInWithGoogle = true;
    return null;
  }

  @override
  Future<String?> signUpWithGoogle() async {
    return signInWithGoogle();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> deleteAccount() async {
    return null;
  }
}

void main() {
  group('McProviderLoginView Widget Tests', () {
    late FakeMcProviderAuthController fakeAuthController;

    setUp(() {
      fakeAuthController = FakeMcProviderAuthController();
    });

    Widget createTestWidget() {
      return Sizer(
        builder: (context, orientation, deviceType) {
          return ChangeNotifierProvider<McProviderAuthController>.value(
            value: fakeAuthController,
            child: const MaterialApp(
              home: McProviderLoginView(),
            ),
          );
        },
      );
    }

    testWidgets('should render login view elements correctly', (WidgetTester tester) async {
      // Set physical size for standard mobile view
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for main title and descriptive text
      expect(find.text('Service Provider Login'), findsOneWidget);
      expect(find.text('Log in to manage your maintenance contracts.'), findsOneWidget);

      // Check for email and password fields
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Check for Login button
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

      // Check for Google Sign-In button
      expect(find.text('Sign In with Google'), findsOneWidget);

      // Check for registration link
      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('should show form validation errors for empty fields on tap', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the login button without filling any data
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify that validation warning messages are shown
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should update email and password fields on text inputs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the email field and enter text
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'provider@company.com');
      
      // Find the password field and enter text
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'SecurePassword123!');
      
      await tester.pumpAndSettle();

      // Verify entered text
      expect(find.text('provider@company.com'), findsOneWidget);
      expect(find.text('SecurePassword123!'), findsOneWidget);
    });

    testWidgets('should display loading spinner when controller is loading', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Set loading state to true
      fakeAuthController.setLoading(true);
      await tester.pump();

      // Login text should be replaced with progress indicator
      expect(find.text('Login'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });

    testWidgets('should call signInWithGoogle when Google Sign-In button is tapped', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final googleButton = find.text('Sign In with Google');
      expect(googleButton, findsOneWidget);

      await tester.tap(googleButton);
      await tester.pump();

      expect(fakeAuthController.didCallSignInWithGoogle, true);
    });
  });
}
