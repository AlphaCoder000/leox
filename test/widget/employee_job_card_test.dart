import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/employee_job_card.dart';
import 'package:leox/models/job_model.dart';

void main() {
  group('EmployeeJobCard Widget Tests', () {
    late JobModel testJob;
    late VoidCallback mockOnView;

    setUp(() {
      testJob = JobModel(
        id: 'test-job-1',
        title: 'Senior Flutter Developer',
        department: 'Engineering',
        category: 'Software Development',
        location: 'Remote',
        jobType: 'full-time',
        status: 'Open',
        description: 'We are looking for a senior Flutter developer...',
        requirements: ['5+ years of Flutter experience', 'Dart knowledge'],
        salaryRange: '\$120,000 - \$150,000',
        postedOn: DateTime(2024, 1, 15),
        employerId: 'employer-123',
        companyName: 'Tech Company',
      );
      mockOnView = () {};
    });

    testWidgets('should display job information correctly', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: testJob,
                  onView: mockOnView,
                ),
              ),
            );
          },
        ),
      );

      // Check if the card is rendered
      expect(find.byType(EmployeeJobCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // Check if job title is displayed
      expect(find.text('Senior Flutter Developer'), findsOneWidget);

      // Check if department is displayed
      expect(find.text('Engineering'), findsOneWidget);

      // Check if posted date is displayed
      expect(find.text('Posted on 15/1/2024'), findsOneWidget);

      // Check if View button is present
      expect(find.text('View'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should display status chip correctly', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: testJob,
                  onView: mockOnView,
                ),
              ),
            );
          },
        ),
      );

      // Check if status chip is displayed
      expect(find.text('Open'), findsOneWidget);
      expect(find.byType(Container), findsWidgets); // Status chip is a Container
    });

    testWidgets('should handle different job statuses', (WidgetTester tester) async {
      // Test with "Closed" status
      final closedJob = JobModel(
        id: 'test-job-2',
        title: 'Junior Developer',
        department: 'Engineering',
        category: 'Software Development',
        location: 'On-site',
        jobType: 'full-time',
        status: 'Closed',
        description: 'Junior developer position...',
        requirements: ['2+ years of experience'],
        salaryRange: '\$60,000 - \$80,000',
        postedOn: DateTime(2024, 2, 1),
        employerId: 'employer-456',
        companyName: 'Another Company',
      );

      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: closedJob,
                  onView: mockOnView,
                ),
              ),
            );
          },
        ),
      );

      // Check if closed status is displayed
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Junior Developer'), findsOneWidget);
    });

    testWidgets('should call onView when View button is pressed', (WidgetTester tester) async {
      bool viewPressed = false;
      testOnView() {
        viewPressed = true;
      }

      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: testJob,
                  onView: testOnView,
                ),
              ),
            );
          },
        ),
      );

      // Tap the View button
      await tester.tap(find.text('View'));
      await tester.pump();

      // Verify onView was called
      expect(viewPressed, isTrue);
    });

    testWidgets('should have correct card styling', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: testJob,
                  onView: mockOnView,
                ),
              ),
            );
          },
        ),
      );

      // Check card styling
      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.elevation, equals(2.0));
      expect(cardWidget.shape, isA<RoundedRectangleBorder>());
      
      final roundedRectBorder = cardWidget.shape as RoundedRectangleBorder;
      expect(roundedRectBorder.borderRadius, BorderRadius.circular(16));
      expect(roundedRectBorder.side, isA<BorderSide>());
    });

    testWidgets('should handle long job titles', (WidgetTester tester) async {
      final longTitleJob = JobModel(
        id: 'test-job-3',
        title: 'Very Long Job Title That Should Be Truncated Or Wrapped Properly Without Breaking The Layout',
        department: 'Engineering',
        category: 'Software Development',
        location: 'Remote',
        jobType: 'full-time',
        status: 'Open',
        description: 'Job description...',
        requirements: ['Requirements...'],
        salaryRange: '\$100,000',
        postedOn: DateTime(2024, 3, 1),
        employerId: 'employer-789',
        companyName: 'Test Company',
      );

      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: longTitleJob,
                  onView: mockOnView,
                ),
              ),
            );
          },
        ),
      );

      // Should render without errors
      expect(find.byType(EmployeeJobCard), findsOneWidget);
      expect(tester.takeException(), isNull);
      
      // Should display the long title
      expect(find.textContaining('Very Long Job Title'), findsOneWidget);
    });

    testWidgets('should display date in correct format', (WidgetTester tester) async {
      final jobWithSpecificDate = JobModel(
        id: 'test-job-4',
        title: 'Test Job',
        department: 'Testing',
        category: 'Quality Assurance',
        location: 'Office',
        jobType: 'part-time',
        status: 'Open',
        description: 'Test description',
        requirements: ['Test requirements'],
        salaryRange: '\$50,000',
        postedOn: DateTime(2024, 12, 25), // Christmas day
        employerId: 'employer-999',
        companyName: 'Holiday Company',
      );

      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: EmployeeJobCard(
                  job: jobWithSpecificDate,
                  onView: mockOnView,
                ),
              ),
            );
          },
        ),
      );

      // Check if date is displayed in correct format
      expect(find.text('Posted on 25/12/2024'), findsOneWidget);
    });
  });
}
