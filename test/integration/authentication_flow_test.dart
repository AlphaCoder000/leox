import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:leox/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Employee Authentication Flow Tests', () {
    testWidgets('complete employee registration flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test role selection
      expect(find.text('Welcome to LeoOpus'), findsOneWidget);
      expect(find.text('I am looking for a job'), findsOneWidget);
      
      await tester.tap(find.text('I am looking for a job'));
      await tester.pumpAndSettle();

      // Test employee registration
      expect(find.text('Employee Registration'), findsOneWidget);
      
      // Fill registration form
      await tester.enterText(find.byKey(const Key('name_field')), 'John Doe');
      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@test.com');
      await tester.enterText(find.byKey(const Key('phone_field')), '+1234567890');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'Test@123');

      // Submit form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.text('Employee Dashboard'), findsOneWidget);
    });

    testWidgets('employee login flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('I am looking for a job'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      // Test login
      expect(find.text('Employee Login'), findsOneWidget);
      
      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.text('Employee Dashboard'), findsOneWidget);
    });

    testWidgets('employee logout flow', (WidgetTester tester) async {
      // Start the app and login
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('I am looking for a job'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Test logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify return to welcome screen
      expect(find.text('Welcome to LeoOpus'), findsOneWidget);
    });
  });

  group('Employer Authentication Flow Tests', () {
    testWidgets('complete employer registration flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test role selection
      expect(find.text('Welcome to LeoOpus'), findsOneWidget);
      expect(find.text('I am hiring'), findsOneWidget);
      
      await tester.tap(find.text('I am hiring'));
      await tester.pumpAndSettle();

      // Test employer registration
      expect(find.text('Employer Registration'), findsOneWidget);
      
      // Fill registration form
      await tester.enterText(find.byKey(const Key('company_name_field')), 'Tech Corp');
      await tester.enterText(find.byKey(const Key('email_field')), 'hr@techcorp.com');
      await tester.enterText(find.byKey(const Key('phone_field')), '+1234567890');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'Test@123');
      await tester.enterText(find.byKey(const Key('linkedin_field')), 'https://linkedin.com/company/techcorp');

      // Submit form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.text('Employer Dashboard'), findsOneWidget);
    });

    testWidgets('employer login flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('I am hiring'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      // Test login
      expect(find.text('Employer Login'), findsOneWidget);
      
      await tester.enterText(find.byKey(const Key('email_field')), 'hr@techcorp.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.text('Employer Dashboard'), findsOneWidget);
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('employee navigation flow', (WidgetTester tester) async {
      // Start the app and login as employee
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('I am looking for a job'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Test navigation between screens
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      // Navigate to Jobs
      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();
      expect(find.text('Available Jobs'), findsOneWidget);

      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('My Profile'), findsOneWidget);

      // Navigate to Applications
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('My Applications'));
      await tester.pumpAndSettle();
      expect(find.text('My Applications'), findsOneWidget);
    });

    testWidgets('employer navigation flow', (WidgetTester tester) async {
      // Start the app and login as employer
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('I am hiring'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'hr@techcorp.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Test navigation between screens
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      // Navigate to Jobs
      await tester.tap(find.text('My Jobs'));
      await tester.pumpAndSettle();
      expect(find.text('My Job Postings'), findsOneWidget);

      // Navigate to Candidates
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Candidates'));
      await tester.pumpAndSettle();
      expect(find.text('Candidates'), findsOneWidget);

      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Company Profile'), findsOneWidget);
    });
  });
}
