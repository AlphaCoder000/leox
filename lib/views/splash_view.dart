import 'package:flutter/material.dart';
import 'package:leox/utils/route_guard.dart';
import 'package:leox/views/welcome_view.dart';
import 'package:leox/views/employee/employee_dashboard_view.dart';
import 'package:sizer/sizer.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      // Check if user is already authenticated
      final isAuthenticated = await RouteGuard.isUserAuthenticated();
      final role = await RouteGuard.getUserRole();

      if (!mounted) return;

      debugPrint(
        '[SplashView] Auth check complete: authenticated=$isAuthenticated, role=$role',
      );

      if (isAuthenticated && role == 'employee') {
        // User is authenticated as employee, go to dashboard
        debugPrint(
          '[SplashView] Authenticated user detected, navigating to dashboard',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeDashboardView()),
        );
      } else {
        // Not authenticated or is employer, go to welcome/role selection
        debugPrint('[SplashView] No authentication found, showing welcome screen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: Text(
          "LeoRecruit",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(66, 133, 244, 1),
          ),
        ),
      ),
    );
  }
}
