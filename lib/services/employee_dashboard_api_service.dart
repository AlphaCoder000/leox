import 'api_service.dart';
import '../models/employee_dashboard_model.dart';

/// Employee Dashboard API Service
///
/// Handles all dashboard-related API calls for employees:
/// - Dashboard statistics and summary
/// - Recent applications
/// - Profile completion status
class EmployeeDashboardApiService {
  /// Fetch dashboard data for the current employee
  ///
  /// Includes:
  /// - Application statistics (total, under review, accepted, rejected)
  /// - Recent applications and rejections
  /// - Profile completion percentage
  /// - Improvement suggestions
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: EmployeeDashboardModel with aggregated data
  static Future<EmployeeDashboardModel> getDashboard({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/dashboard',
        authToken: authToken,
      );

      // Parse response and create model
      return EmployeeDashboardModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get dashboard statistics only (lighter payload)
  ///
  /// Useful for quick stats updates without full dashboard refresh
  ///
  /// Returns: {totalApplications, underReview, accepted, rejected}
  static Future<Map<String, dynamic>> getStats({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/dashboard/stats',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get recent applications
  ///
  /// [limit] - Max number of recent applications to return, default 5
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {applications: [EmployeeApplicationModel]}
  static Future<Map<String, dynamic>> getRecentApplications({
    int limit = 5,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/dashboard/recent-applications?limit=$limit',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get recent rejections
  ///
  /// [limit] - Max number of rejections, default 3
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {rejections: [EmployeeApplicationModel]}
  static Future<Map<String, dynamic>> getRecentRejections({
    int limit = 3,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/dashboard/recent-rejections?limit=$limit',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get profile completion status
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {percentage: int, suggestions: [string]}
  static Future<Map<String, dynamic>> getProfileCompletion({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/dashboard/profile-completion',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Dismiss a profile suggestion (user acknowledges it)
  ///
  /// [suggestionId] - ID of suggestion to dismiss
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {message}
  static Future<Map<String, dynamic>> dismissSuggestion({
    required String suggestionId,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.post(
        '/employee/dashboard/dismiss-suggestion',
        body: {'suggestionId': suggestionId},
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
