import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:leox/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Job Application Flow Tests', () {
    testWidgets('complete job application flow', (WidgetTester tester) async {
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

      // Navigate to Jobs
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();

      // Search for jobs
      expect(find.text('Available Jobs'), findsOneWidget);
      
      // Test search functionality
      await tester.enterText(find.byKey(const Key('search_field')), 'Software Engineer');
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Full-time'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // Select a job
      await tester.tap(find.text('Senior Software Engineer'));
      await tester.pumpAndSettle();

      // View job details
      expect(find.text('Job Details'), findsOneWidget);
      expect(find.text('Company: Tech Corp'), findsOneWidget);
      expect(find.text('Location: San Francisco, CA'), findsOneWidget);
      expect(find.text('Salary: \$120,000 - \$180,000'), findsOneWidget);

      // Apply for job
      await tester.tap(find.byKey(const Key('apply_button')));
      await tester.pumpAndSettle();

      // Fill application form
      expect(find.text('Job Application'), findsOneWidget);
      
      await tester.enterText(find.byKey(const Key('cover_letter_field')), 
        'I am excited to apply for this position. With my 5 years of experience in software development...');
      
      // Upload resume (mock)
      await tester.tap(find.byKey(const Key('upload_resume_button')));
      await tester.pumpAndSettle();

      // Submit application
      await tester.tap(find.byKey(const Key('submit_application_button')));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Application submitted successfully!'), findsOneWidget);

      // Navigate to My Applications
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('My Applications'));
      await tester.pumpAndSettle();

      // Verify application appears in list
      expect(find.text('My Applications'), findsOneWidget);
      expect(find.text('Senior Software Engineer'), findsOneWidget);
      expect(find.text('Applied'), findsOneWidget);
    });

    testWidgets('job application with different status transitions', (WidgetTester tester) async {
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

      // Navigate to My Applications
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('My Applications'));
      await tester.pumpAndSettle();

      // Test application status tracking
      expect(find.text('Applied'), findsOneWidget);
      
      // View application details
      await tester.tap(find.text('Senior Software Engineer'));
      await tester.pumpAndSettle();

      // Verify application details
      expect(find.text('Application Details'), findsOneWidget);
      expect(find.text('Applied on:'), findsOneWidget);
      expect(find.text('Status: Applied'), findsOneWidget);
      
      // Test withdrawal functionality
      await tester.tap(find.byKey(const Key('withdraw_button')));
      await tester.pumpAndSettle();

      // Confirm withdrawal
      await tester.tap(find.text('Yes, Withdraw'));
      await tester.pumpAndSettle();

      // Verify withdrawal success
      expect(find.text('Application withdrawn successfully'), findsOneWidget);
    });
  });

  group('Job Posting Flow Tests', () {
    testWidgets('complete job posting flow', (WidgetTester tester) async {
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

      // Navigate to Create Job
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Create Job'));
      await tester.pumpAndSettle();

      // Fill job posting form
      expect(find.text('Create Job Posting'), findsOneWidget);
      
      await tester.enterText(find.byKey(const Key('job_title_field')), 'Senior Flutter Developer');
      await tester.enterText(find.byKey(const Key('job_description_field')), 
        'We are looking for an experienced Flutter developer...');
      await tester.enterText(find.byKey(const Key('requirements_field')), 
        '5+ years of Flutter experience, Dart proficiency...');
      await tester.enterText(find.byKey(const Key('salary_min_field')), '100000');
      await tester.enterText(find.byKey(const Key('salary_max_field')), '150000');
      await tester.enterText(find.byKey(const Key('location_field')), 'Remote');

      // Select job type
      await tester.tap(find.byKey(const Key('job_type_dropdown')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Full-time'));
      await tester.pumpAndSettle();

      // Select experience level
      await tester.tap(find.byKey(const Key('experience_level_dropdown')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Senior Level'));
      await tester.pumpAndSettle();

      // Post job
      await tester.tap(find.byKey(const Key('post_job_button')));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Job posted successfully!'), findsOneWidget);

      // Navigate to My Jobs
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('My Jobs'));
      await tester.pumpAndSettle();

      // Verify job appears in list
      expect(find.text('My Job Postings'), findsOneWidget);
      expect(find.text('Senior Flutter Developer'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('job posting management flow', (WidgetTester tester) async {
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

      // Navigate to My Jobs
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('My Jobs'));
      await tester.pumpAndSettle();

      // Select a job to edit
      await tester.tap(find.text('Senior Flutter Developer'));
      await tester.pumpAndSettle();

      // Test job editing
      await tester.tap(find.byKey(const Key('edit_job_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('job_description_field')), 
        'We are looking for an experienced Flutter developer (Updated)...');
      
      await tester.tap(find.byKey(const Key('update_job_button')));
      await tester.pumpAndSettle();

      // Verify update success
      expect(find.text('Job updated successfully!'), findsOneWidget);

      // Test job deactivation
      await tester.tap(find.byKey(const Key('deactivate_job_button')));
      await tester.pumpAndSettle();

      // Confirm deactivation
      await tester.tap(find.text('Yes, Deactivate'));
      await tester.pumpAndSettle();

      // Verify deactivation
      expect(find.text('Job deactivated successfully'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
    });
  });

  group('Candidate Management Flow Tests', () {
    testWidgets('candidate review and management flow', (WidgetTester tester) async {
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

      // Navigate to Candidates
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Candidates'));
      await tester.pumpAndSettle();

      // View candidates for a job
      expect(find.text('Candidates'), findsOneWidget);
      expect(find.text('Senior Flutter Developer'), findsOneWidget);
      expect(find.text('5 Applications'), findsOneWidget);

      // View candidate details
      await tester.tap(find.text('View Candidates'));
      await tester.pumpAndSettle();

      // Review candidate application
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Verify candidate information
      expect(find.text('Candidate Profile'), findsOneWidget);
      expect(find.text('Email: john.doe@test.com'), findsOneWidget);
      expect(find.text('Phone: +1234567890'), findsOneWidget);
      expect(find.text('Cover Letter:'), findsOneWidget);

      // Test candidate actions
      await tester.tap(find.byKey(const Key('shortlist_button')));
      await tester.pumpAndSettle();

      expect(find.text('Candidate shortlisted'), findsOneWidget);

      // Test scheduling interview
      await tester.tap(find.byKey(const Key('schedule_interview_button')));
      await tester.pumpAndSettle();

      // Fill interview details
      await tester.enterText(find.byKey(const Key('interview_date_field')), '2024-02-15');
      await tester.enterText(find.byKey(const Key('interview_time_field')), '10:00 AM');
      await tester.enterText(find.byKey(const Key('interview_location_field')), 'Video Call');

      await tester.tap(find.byKey(const Key('schedule_button')));
      await tester.pumpAndSettle();

      // Verify interview scheduled
      expect(find.text('Interview scheduled successfully'), findsOneWidget);
    });
  });
}
