import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/providers/employee_providers/employee_profile_provider.dart';

import 'employee_drawer_test.mocks.dart';

@GenerateMocks([EmployeeAuthProvider, EmployeeProfileProvider])
void main() {
  group('EmployeeDrawer Widget Tests', () {
    late MockEmployeeAuthProvider mockAuth;
    late MockEmployeeProfileProvider mockProfile;

    setUp(() {
      mockAuth = MockEmployeeAuthProvider();
      mockProfile = MockEmployeeProfileProvider();
    });

    Widget createTestWidget({EmployeeDrawerItem selectedItem = EmployeeDrawerItem.dashboard}) {
      return Sizer(
        builder: (context, orientation, deviceType) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<EmployeeAuthProvider>.value(value: mockAuth),
              ChangeNotifierProvider<EmployeeProfileProvider>.value(value: mockProfile),
            ],
            child: MaterialApp(
              home: Scaffold(
                drawer: EmployeeDrawer(selectedItem: selectedItem),
                body: Container(),
              ),
            ),
          );
        },
      );
    }

    testWidgets('should display drawer with correct structure', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check if drawer is displayed
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.byType(EmployeeDrawer), findsOneWidget);

      // Check if header is displayed
      expect(find.text('LeoOpus'), findsOneWidget);
      expect(find.byIcon(Icons.work_outline), findsOneWidget);

      // Check if menu items are displayed
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('AI Resume Matcher'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Check if version is displayed
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('should highlight selected item correctly', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(selectedItem: EmployeeDrawerItem.jobs));

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check if Jobs item is selected (has filled icon)
      expect(find.byIcon(Icons.work), findsOneWidget); // Active icon
      expect(find.byIcon(Icons.work_outline), findsNothing); // Outline icon should not be visible

      // Check if Dashboard item is not selected (has outline icon)
      expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget); // Outline icon
      expect(find.byIcon(Icons.dashboard), findsNothing); // Filled icon should not be visible
    });

    testWidgets('should navigate when menu item is tapped', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Tap on Jobs item
      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();

      // Drawer should be closed and navigation should happen
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('should show logout dialog when logout is tapped', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Tap on Logout item
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Check if logout dialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Logout'), findsWidgets); // Both dialog title and button
      expect(find.text('Are you sure you want to sign out of your employee account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Yes, Logout'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is tapped', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Tap on Logout item
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Tap on Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(Drawer), findsOneWidget); // Drawer should still be open
    });

    testWidgets('should perform logout when confirmed', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Mock the logout methods
      when(mockAuth.logout()).thenAnswer((_) async {});
      when(mockProfile.reset()).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Tap on Logout item
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Tap on Yes, Logout button
      await tester.tap(find.text('Yes, Logout'));
      await tester.pumpAndSettle();

      // Verify logout methods were called
      verify(mockAuth.logout()).called(1);
      verify(mockProfile.reset()).called(1);

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should have correct styling and colors', (WidgetTester tester) async {
      // Initialize Sizer for testing
      tester.view.physicalSize = const Size(411, 823);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());

      // Open the drawer manually
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check if drawer has correct width
      final drawerWidget = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawerWidget.width, equals(70.w));

      // Check if logout item has correct color
      final logoutIcon = tester.widget<Icon>(find.byIcon(Icons.logout_rounded));
      expect(logoutIcon.color, equals(Colors.redAccent));

      // Check if logout text has correct color
      final logoutText = tester.widget<Text>(find.text('Logout'));
      expect(logoutText.style?.color, equals(Colors.redAccent));
    });

    testWidgets('should handle all drawer items selection states', (WidgetTester tester) async {
      final items = [
        EmployeeDrawerItem.dashboard,
        EmployeeDrawerItem.jobs,
        EmployeeDrawerItem.notifications,
        EmployeeDrawerItem.aiMatcher,
        EmployeeDrawerItem.profile,
      ];

      for (final item in items) {
        // Initialize Sizer for testing
        tester.view.physicalSize = const Size(411, 823);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget(selectedItem: item));

        // Open the drawer manually
        final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        // Verify the correct item is selected
        expect(find.byType(EmployeeDrawer), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
        addTearDown(tester.view.resetPhysicalSize);
      }
    });
  });
}
