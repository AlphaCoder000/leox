import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:leox/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Resume Matcher Flow Tests', () {
    testWidgets('employee AI resume matching flow', (WidgetTester tester) async {
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

      // Navigate to AI Resume Matcher
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('AI Resume Matcher'));
      await tester.pumpAndSettle();

      // Verify AI matcher interface
      expect(find.text('AI Resume Matcher'), findsOneWidget);
      expect(find.text('Find jobs that match your skills and experience'), findsOneWidget);

      // Upload resume
      await tester.tap(find.byKey(const Key('upload_resume_button')));
      await tester.pumpAndSettle();

      // Wait for AI processing
      expect(find.text('Analyzing your resume...'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));

      // View matching results
      expect(find.text('Job Matches Found'), findsOneWidget);
      expect(find.text('95% Match'), findsOneWidget);
      expect(find.text('Senior Flutter Developer'), findsOneWidget);

      // View match details
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      // Verify match analysis
      expect(find.text('Match Analysis'), findsOneWidget);
      expect(find.text('Skills Match: 95%'), findsOneWidget);
      expect(find.text('Experience Match: 90%'), findsOneWidget);
      expect(find.text('Education Match: 85%'), findsOneWidget);

      // Apply for matched job
      await tester.tap(find.byKey(const Key('apply_matched_job_button')));
      await tester.pumpAndSettle();

      expect(find.text('Application submitted successfully!'), findsOneWidget);
    });

    testWidgets('employer AI candidate matching flow', (WidgetTester tester) async {
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

      // Navigate to AI Resume Matcher
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('AI Resume Matcher'));
      await tester.pumpAndSettle();

      // Verify AI matcher interface
      expect(find.text('AI Candidate Matcher'), findsOneWidget);
      expect(find.text('Find candidates that match your job requirements'), findsOneWidget);

      // Select job to match candidates
      await tester.tap(find.byKey(const Key('job_selection_dropdown')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Senior Flutter Developer'));
      await tester.pumpAndSettle();

      // Start AI matching
      await tester.tap(find.byKey(const Key('find_candidates_button')));
      await tester.pumpAndSettle();

      // Wait for AI processing
      expect(find.text('Finding matching candidates...'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));

      // View matching results
      expect(find.text('Candidate Matches Found'), findsOneWidget);
      expect(find.text('92% Match'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);

      // View candidate details
      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();

      // Verify match analysis
      expect(find.text('Candidate Match Analysis'), findsOneWidget);
      expect(find.text('Technical Skills: 95%'), findsOneWidget);
      expect(find.text('Experience: 90%'), findsOneWidget);
      expect(find.text('Cultural Fit: 85%'), findsOneWidget);

      // Shortlist candidate
      await tester.tap(find.byKey(const Key('shortlist_candidate_button')));
      await tester.pumpAndSettle();

      expect(find.text('Candidate shortlisted successfully'), findsOneWidget);
    });
  });

  group('Profile Management Flow Tests', () {
    testWidgets('employee profile completion flow', (WidgetTester tester) async {
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

      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify profile interface
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Profile Completion: 75%'), findsOneWidget);

      // Complete profile information
      await tester.tap(find.byKey(const Key('edit_profile_button')));
      await tester.pumpAndSettle();

      // Fill missing information
      await tester.enterText(find.byKey(const Key('bio_field')), 
        'Experienced software developer with 5+ years in mobile development...');
      await tester.enterText(find.byKey(const Key('experience_field')), '5 years');
      await tester.enterText(find.byKey(const Key('education_field')), 'Bachelor of Computer Science');
      await tester.enterText(find.byKey(const Key('skills_field')), 'Flutter, Dart, Firebase, Git');

      // Add portfolio link
      await tester.enterText(find.byKey(const Key('portfolio_field')), 'https://johndoe.dev');

      // Save profile
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Verify profile updated
      expect(find.text('Profile updated successfully!'), findsOneWidget);
      expect(find.text('Profile Completion: 100%'), findsOneWidget);
    });

    testWidgets('employer profile completion flow', (WidgetTester tester) async {
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

      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify profile interface
      expect(find.text('Company Profile'), findsOneWidget);
      expect(find.text('Profile Completion: 60%'), findsOneWidget);

      // Complete profile information
      await tester.tap(find.byKey(const Key('edit_profile_button')));
      await tester.pumpAndSettle();

      // Fill missing information
      await tester.enterText(find.byKey(const Key('company_description_field')), 
        'Tech Corp is a leading technology company specializing in mobile applications...');
      await tester.enterText(find.byKey(const Key('company_size_field')), '100-500');
      await tester.enterText(find.byKey(const Key('industry_field')), 'Technology');
      await tester.enterText(find.byKey(const Key('founded_field')), '2015');

      // Add company website
      await tester.enterText(find.byKey(const Key('website_field')), 'https://techcorp.com');

      // Save profile
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Verify profile updated
      expect(find.text('Profile updated successfully!'), findsOneWidget);
      expect(find.text('Profile Completion: 100%'), findsOneWidget);
    });
  });

  group('Notification Flow Tests', () {
    testWidgets('notification management flow', (WidgetTester tester) async {
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

      // Navigate to Notifications
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();

      // Verify notifications interface
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('You have 3 new notifications'), findsOneWidget);

      // Test notification interactions
      await tester.tap(find.text('Your application was viewed'));
      await tester.pumpAndSettle();

      // Verify notification details
      expect(find.text('Application Status Update'), findsOneWidget);
      expect(find.text('Tech Corp viewed your application for Senior Flutter Developer'), findsOneWidget);

      // Mark as read
      await tester.tap(find.byKey(const Key('mark_read_button')));
      await tester.pumpAndSettle();

      // Verify notification marked as read
      expect(find.text('Marked as read'), findsOneWidget);

      // Test notification filtering
      await tester.tap(find.byKey(const Key('filter_notifications_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unread only'));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Showing unread notifications'), findsOneWidget);

      // Clear all notifications
      await tester.tap(find.byKey(const Key('clear_all_button')));
      await tester.pumpAndSettle();

      // Confirm clear
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Verify notifications cleared
      expect(find.text('All notifications cleared'), findsOneWidget);
      expect(find.text('No notifications'), findsOneWidget);
    });
  });

  group('Error Handling Flow Tests', () {
    testWidgets('network error handling flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Simulate network error by trying to login without internet
      await tester.tap(find.text('I am looking for a job'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'Test@123');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Unable to connect to server. Please check your internet connection.'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Verify retry attempt
      expect(find.text('Retrying...'), findsOneWidget);
    });

    testWidgets('form validation error handling', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to employee registration
      await tester.tap(find.text('I am looking for a job'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Test invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Test weak password
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });
  });
}
