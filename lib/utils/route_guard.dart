import 'package:flutter/material.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/services/session_service.dart';
import 'package:leox/utils/error_handler_ui.dart';
import 'package:provider/provider.dart';

/// Route Guard Helper
/// Handles authentication checks and protected route navigation
class RouteGuard {
  /// Check if user is authenticated (has valid token)
  static Future<bool> isUserAuthenticated() async {
    try {
      final token = await SessionService.getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('[RouteGuard] Auth check failed: $e');
      return false;
    }
  }

  /// Get the user's role from session
  static Future<String?> getUserRole() async {
    try {
      return await SessionService.getRole();
    } catch (e) {
      debugPrint('[RouteGuard] Role retrieval failed: $e');
      return null;
    }
  }

  /// Navigate to employee dashboard with auth check
  static void navigateToEmployeeDashboard(BuildContext context) {
    if (!context.mounted) return;

    final authProvider = context.read<EmployeeAuthProvider>();

    // Check if user is already logged in
    if (!authProvider.isLoggedIn) {
      debugPrint('[RouteGuard] User not authenticated, blocking dashboard access');
      ErrorHandlerUI.showErrorSnackbar(context, 'Please login first');
      return;
    }

    // If logged in, navigate
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/employee-dashboard', (route) => false);
  }

  /// Navigate to employee profile with auth check
  static void navigateToEmployeeProfile(BuildContext context) {
    if (!context.mounted) return;

    final authProvider = context.read<EmployeeAuthProvider>();

    if (!authProvider.isLoggedIn) {
      debugPrint('[RouteGuard] User not authenticated, blocking profile access');
      ErrorHandlerUI.showErrorSnackbar(context, 'Please login first');
      return;
    }

    Navigator.of(context).pushNamed('/employee-profile');
  }

  /// Navigate to employee jobs with auth check
  static void navigateToEmployeeJobs(BuildContext context) {
    if (!context.mounted) return;

    final authProvider = context.read<EmployeeAuthProvider>();

    if (!authProvider.isLoggedIn) {
      debugPrint('[RouteGuard] User not authenticated, blocking jobs access');
      ErrorHandlerUI.showErrorSnackbar(context, 'Please login first');
      return;
    }

    Navigator.of(context).pushNamed('/employee-jobs');
  }

  /// Validate session on app resume
  /// Checks if token is still valid and user session is intact
  static Future<bool> validateSession(BuildContext context) async {
    try {
      final isAuthenticated = await isUserAuthenticated();

      if (!isAuthenticated && context.mounted) {
        debugPrint('[RouteGuard] Session validation failed - user logged out');
        // Clear auth state if token is invalid
        context.read<EmployeeAuthProvider>().logout();
        return false;
      }

      debugPrint('[RouteGuard] Session validation successful');
      return true;
    } catch (e) {
      debugPrint('[RouteGuard] Session validation error: $e');
      return false;
    }
  }

  /// Handle logout with route clearing
  static Future<void> handleLogout(BuildContext context) async {
    if (!context.mounted) return;

    try {
      final authProvider = context.read<EmployeeAuthProvider>();
      await authProvider.logout();

      if (context.mounted) {
        // Clear all routes and go to role selection
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/role-option', (route) => false);

        ErrorHandlerUI.showSuccessSnackbar(context, 'Logged out successfully');
      }
    } catch (e) {
      debugPrint('[RouteGuard] Logout error: $e');
      if (context.mounted) {
        ErrorHandlerUI.showErrorSnackbar(context, 'Logout failed');
      }
    }
  }
}
