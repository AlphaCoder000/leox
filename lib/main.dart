import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart';
import 'providers/employee_providers/employee_auth_provider.dart';
import 'providers/employer_auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/employee_providers/employee_dashboard_provider.dart';
import 'providers/employer_profile_provider.dart';
import 'providers/employer_dashboard_provider.dart';
import 'providers/employer_jobs_provider.dart';
import 'providers/theme_povider.dart';
import 'providers/employee_providers/employee_jobs_provider.dart';
import 'providers/employee_providers/employee_profile_provider.dart';
import 'providers/employer_candidates_provider.dart';
import 'services/session_service.dart';
import 'services/firebase_service.dart';
import 'services/profile_service.dart';
import 'backend/server_actions.dart';
import 'backend/ai_workflows.dart';
import 'views/splash_view.dart';
import 'utils/route_guard.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Main] Firebase initialized successfully');
    debugPrint('[Main] Project ID: ${Firebase.app().options.projectId}');
  } catch (e) {
    debugPrint('[Main] Firebase initialization failed: $e');
    debugPrint('[Main] App will continue without Firebase');
  }

  runApp(
    MultiProvider(
      providers: [
        // Core Services
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        Provider<ProfileService>(create: (_) => ProfileService()),
        Provider<ServerActions>(create: (_) => ServerActions()),
        Provider<AIWorkflows>(create: (_) => AIWorkflows()),
        
        // Connectivity
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()..initialize()),
        
        // Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Employer Providers
        ChangeNotifierProvider(create: (_) => EmployerAuthProvider()),
        ChangeNotifierProvider(
          create: (_) => EmployerDashboardProvider()..loadDummyData(),
        ),
        ChangeNotifierProvider(create: (_) => EmployerJobsProvider()),
        ChangeNotifierProvider(create: (_) => EmployerCandidatesProvider()),
        ChangeNotifierProvider(create: (_) => EmployerProfileProvider()),
        
        // Employee Providers
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
