import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/employee_dashboard_model.dart';
import '../../services/employee_dashboard_api_service.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class EmployeeDashboardProvider extends ChangeNotifier {
  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployeeDashboardModel _dashboard = EmployeeDashboardModel.empty();
  EmployeeDashboardModel get dashboard => _dashboard;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  // ======== PRIVATE METHODS ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ======== PUBLIC METHODS ========

  /// Fetch complete dashboard data from API
  ///
  /// Includes:
  /// - Application statistics
  /// - Recent applications and rejections
  /// - Profile completion status
  ///
  /// Logs: Fetch attempt, success, and errors
  Future<void> loadDashboard() async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token from session
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated. Please login first.');
      }

      // LOG: Fetch initiation
      debugPrint('[EmployeeDashboardProvider] Loading dashboard...');

      // Call API
      final dashboard = await EmployeeDashboardApiService.getDashboard(
        authToken: authToken,
      );

      _dashboard = dashboard;
      _lastUpdated = DateTime.now();

      // LOG: Success
      debugPrint('[EmployeeDashboardProvider] Dashboard loaded:');
      debugPrint('  - Total applications: ${dashboard.totalApplications}');
      debugPrint('  - Under review: ${dashboard.applicationsUnderReview}');
      debugPrint('  - Accepted: ${dashboard.acceptedOffers}');
      debugPrint(
        '  - Profile completion: ${dashboard.profileCompletionPercentage}%',
      );
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeDashboardProvider] API Error: ${e.message}');
    } catch (e) {
      _setError('Failed to load dashboard: $e');
      debugPrint('[EmployeeDashboardProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh dashboard data (faster update)
  ///
  /// Gets only statistics for quick refresh without full payload
  Future<void> refreshStats() async {
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) return;

      // LOG: Refresh attempt
      debugPrint('[EmployeeDashboardProvider] Refreshing stats...');

      // Call API
      final stats = await EmployeeDashboardApiService.getStats(
        authToken: authToken,
      );

      // Update dashboard with new stats
      _dashboard = _dashboard.copyWith(
        totalApplications:
            _parseInt(stats['totalApplications']) ??
            _dashboard.totalApplications,
        applicationsUnderReview:
            _parseInt(stats['applicationsUnderReview']) ??
            _dashboard.applicationsUnderReview,
        acceptedOffers:
            _parseInt(stats['acceptedOffers']) ?? _dashboard.acceptedOffers,
        rejectedApplications:
            _parseInt(stats['rejectedApplications']) ??
            _dashboard.rejectedApplications,
      );

      _lastUpdated = DateTime.now();

      // LOG: Success
      debugPrint('[EmployeeDashboardProvider] Stats refreshed');

      notifyListeners();
    } on ApiException catch (e) {
      debugPrint('[EmployeeDashboardProvider] Refresh error: ${e.message}');
    } catch (e) {
      debugPrint('[EmployeeDashboardProvider] Unexpected error: $e');
    }
  }

  /// Load profile completion data with suggestions
  ///
  /// Useful for profile-focused views
  Future<void> loadProfileCompletion() async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Fetch initiation
      debugPrint('[EmployeeDashboardProvider] Loading profile completion...');

      // Call API
      final completion = await EmployeeDashboardApiService.getProfileCompletion(
        authToken: authToken,
      );

      // Update dashboard with new completion data
      _dashboard = _dashboard.copyWith(
        profileCompletionPercentage:
            _parseInt(completion['percentage']) ??
            _dashboard.profileCompletionPercentage,
        profileSuggestions: _parseStringList(completion['suggestions']),
      );

      // LOG: Success
      debugPrint(
        '[EmployeeDashboardProvider] Profile completion loaded: ${_dashboard.profileCompletionPercentage}%',
      );

      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint(
        '[EmployeeDashboardProvider] Profile completion error: ${e.message}',
      );
    } catch (e) {
      _setError('Failed to load profile completion: $e');
      debugPrint('[EmployeeDashboardProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent applications
  ///
  /// Useful for dashboard card display
  Future<void> loadRecentApplications({int limit = 5}) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Fetch initiation
      debugPrint('[EmployeeDashboardProvider] Loading recent applications...');

      // Call API
      final response = await EmployeeDashboardApiService.getRecentApplications(
        limit: limit,
        authToken: authToken,
      );

      debugPrint(
        '[EmployeeDashboardProvider] Loaded ${response['applications']?.length ?? 0} recent applications',
      );

      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint(
        '[EmployeeDashboardProvider] Recent applications error: ${e.message}',
      );
    } catch (e) {
      _setError('Failed to load recent applications: $e');
      debugPrint('[EmployeeDashboardProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if dashboard data needs refresh (older than 5 minutes)
  bool get needsRefresh {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > 5;
  }

  /// Get time since last update as readable string
  ///
  /// Examples: "Just now", "2 minutes ago", "1 hour ago"
  String getTimeSinceUpdate() {
    if (_lastUpdated == null) return 'Never';

    final difference = DateTime.now().difference(_lastUpdated!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  // ======== BACKWARD COMPATIBILITY (from old provider) ========

  /// Get total applications sent (from dashboard)
  int get applicationsSent => _dashboard.totalApplications;

  /// Get active applications (pending + under review)
  int get activeApplications => _dashboard.pendingApplications;

  /// Notify when application status changes
  ///
  /// (Legacy from old provider, now just updates dashboard)
  void updateApplicationStatus({required bool isActive}) {
    // Trigger refresh to get latest stats
    refreshStats();
  }

  // ======== HELPER FUNCTIONS ========

  /// Parse integer value safely
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse list of strings safely
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }
}
