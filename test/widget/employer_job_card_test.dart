import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/employer_job_card.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/models/job_model.dart';
import 'employer_job_card_test.mocks.dart';

@GenerateMocks([EmployerJobsProvider])
void main() {
  group('Employer Job Card Widget Tests -', () {
    late MockEmployerJobsProvider mockProvider;

    setUp(() {
      mockProvider = MockEmployerJobsProvider();
    });

    testWidgets('Job details are displayed correctly on the card', (WidgetTester tester) async {
      // 1. Create a dummy job
      final testJob = JobModel(
        id: '1', title: 'Senior Flutter Developer', department: 'Engineering', category: 'Software Development',
        description: 'Build amazing apps!', requirements: ['Flutter', 'Dart'], postedOn: DateTime.now(),
        employerId: 'e1', companyName: 'CodeCorp', location: 'Remote',
        jobType: 'Full-time', experienceLevel: 'Senior', salaryRange: '\$120k - \$150k',
        status: 'Open', postedBy: 'e1', applicationCount: 0,
        skills: [], benefits: [],
      );

      // 2. Build the widget inside a pumped environment
      // We must wrap UI components in MaterialApp so they inherit fonts, themes, and navigation!
      // Since your app uses Sizer, we must wrap it in Sizer too!
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: ChangeNotifierProvider<EmployerJobsProvider>.value(
                  value: mockProvider,
                  child: JobCard(job: testJob),
                ),
              ),
            );
          }
        ),
      );

      // 3. Verify exactly what is visible on the screen
      expect(find.text('Senior Flutter Developer'), findsOneWidget);
      expect(find.text('Build amazing apps!'), findsOneWidget);
      expect(find.text('Full-time'), findsOneWidget); // Shows in a chip
      expect(find.text('Open'), findsOneWidget); // Shows in a chip
      
      // We don't expect 'Junior Dev' to be on screen!
      expect(find.text('Junior Dev'), findsNothing);
    });

    testWidgets('Tapping the delete option triggers warning dialog and deletes', (WidgetTester tester) async {
      final testJob = JobModel(
        id: '1', title: 'Senior Flutter Developer', department: 'Engineering', category: 'Software Development',
        description: 'Build amazing apps!', requirements: ['Flutter', 'Dart'], postedOn: DateTime.now(),
        employerId: 'e1', companyName: 'CodeCorp', location: 'Remote',
        jobType: 'Full-time', experienceLevel: 'Senior', salaryRange: '\$120k - \$150k',
        status: 'Open', postedBy: 'e1', applicationCount: 0,
        skills: [], benefits: [],
      );

      // Mock the delete behavior (do nothing, but we record that it was called)
      when(mockProvider.deleteJob(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: ChangeNotifierProvider<EmployerJobsProvider>.value(
                  value: mockProvider,
                  child: JobCard(job: testJob),
                ),
              ),
            );
          }
        ),
      );

      // 1. Find and tap the 3-dots icon
      final moreIcon = find.byIcon(Icons.more_vert_rounded);
      expect(moreIcon, findsOneWidget);
      await tester.tap(moreIcon);
      await tester.pumpAndSettle(); // Fast forward all animations (popup menu dropping down)

      // 2. Find and tap the "Delete" button in the menu
      final menuDeleteText = find.text('Delete');
      expect(menuDeleteText, findsOneWidget);
      await tester.tap(menuDeleteText);
      await tester.pumpAndSettle(); // Wait for confirmation dialog to appear 

      // 3. Let's verify our Warning Dialog actually popped up!
      expect(find.text("Are you sure you want to delete this job posting?"), findsOneWidget);

      // 4. Tap the final definitive Delete button inside the dialog
      // Since there's multiple "Delete" texts now, we find the one that is a TextButton inner child
      final dialogDeleteButton = find.text('Delete').last;
      await tester.tap(dialogDeleteButton); 
      await tester.pumpAndSettle();

      // 5. Verify that our App told the Provider to delete the job!
      verify(mockProvider.deleteJob(testJob)).called(1);
    });
  });
}
