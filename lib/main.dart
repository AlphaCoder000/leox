import 'package:flutter/material.dart';
import 'package:leox/providers/employee/employee_auth_provider.dart';
import 'package:leox/providers/employee/employee_dashboard_provider.dart';
import 'package:leox/providers/employee/employee_jobs_provider.dart';
import 'package:leox/providers/employee/employee_profile_provider.dart';
import 'package:leox/providers/employer_candidates_provider.dart';
import 'package:leox/providers/employer_profile_provider.dart';
import 'package:leox/utils/app_theme.dart';
import 'package:leox/providers/employer_auth_provider.dart';
import 'package:leox/providers/employer_dashboard_provider.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/views/splash_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        //theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        //employer
        ChangeNotifierProvider(create: (_) => EmployerAuthProvider()),
        ChangeNotifierProvider(
          create: (_) => EmployerDashboardProvider()..loadDummyData(),
        ),
        ChangeNotifierProvider(create: (_) => EmployerJobsProvider()),
        ChangeNotifierProvider(create: (_) => EmployerCandidatesProvider()),
        ChangeNotifierProvider(create: (_) => EmployerProfileProvider()),
        //employee
        ChangeNotifierProvider(create: (_) => EmployeeAuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeDashboardProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProfileProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeJobsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      // ✅ THIS WAS MISSING
      builder: (context, orientation, deviceType) {
        return Consumer<ThemeProvider>(
          builder: (context, theme, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              themeMode: theme.themeMode, // Light / Dark / System
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,

              home: const SplashView(),
            );
          },
        );
      },
    );
  }
}
