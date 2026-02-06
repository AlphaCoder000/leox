import 'package:flutter/material.dart';
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
        ChangeNotifierProvider(create: (_) => EmployerAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => EmployerDashboardProvider()..loadDummyData(),
        ),
        ChangeNotifierProvider(create: (_) => EmployerJobsProvider()),
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
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),

              home: const SplashView(),
            );
          },
        );
      },
    );
  }
}
