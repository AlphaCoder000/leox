import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:leox/views/employee/employee_dashboard_view.dart';
import 'package:leox/views/employer/employer_dashboard_view.dart';
import 'package:leox/views/welcome_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart';
import 'providers/employer_auth_provider.dart';
import 'providers/employee_providers/employee_auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/employer_profile_provider.dart';
import 'providers/employer_dashboard_provider.dart';
import 'providers/employer_jobs_provider.dart';
import 'providers/theme_povider.dart';
import 'providers/employee_providers/employee_jobs_provider.dart';
import 'providers/employee_providers/employee_profile_provider.dart';
import 'providers/employer_candidates_provider.dart';
import 'providers/employee_providers/employee_dashboard_provider.dart';
import 'providers/job_application_provider.dart';
// Backend Services
import 'services/firebase_service.dart';
import 'services/profile_service.dart';
import 'services/api_service.dart';
import 'utils/app_theme.dart';
import 'widgets/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure API Service
  ApiService.setBaseUrl('http://localhost:3000/api');  // Back to port 3000
  
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
        // Backend Services
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        Provider<ProfileService>(create: (_) => ProfileService()),
        
        // Connectivity
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()..initialize()),
        
        // Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Employer Providers
        ChangeNotifierProvider(create: (_) => EmployerAuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => EmployerJobsProvider()),
        ChangeNotifierProvider(create: (_) => EmployerCandidatesProvider()),
        ChangeNotifierProvider(create: (_) => EmployerProfileProvider()),
        
        // Employee Providers
        ChangeNotifierProvider(create: (_) => EmployeeAuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeDashboardProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProfileProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeJobsProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
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
      builder: (context, orientation, deviceType) {
        return Consumer<ThemeProvider>(
          builder: (context, theme, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: theme.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const AnimatedSplashScreen(
                duration: Duration(seconds: 4),
                child: WelcomeView(),
              ),
            );
          },
        );
      },
    );
  }
}

class _MainAppContent extends StatelessWidget {
  const _MainAppContent();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const WelcomeView();
        }

        // If user exists, check role from Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {

            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data =
                roleSnapshot.data!.data() as Map<String, dynamic>?;

            final role = data?['role'];

            if (role == 'employer') {
              return const EmployerDashboardView();
            }

            if (role == 'employee') {
              return const EmployeeDashboardView();
            }

            return const WelcomeView();
          },
        );
      },
    );
  }
}
