import 'employee_application_model.dart';

/// Employee Dashboard Model
///
/// Holds aggregated dashboard data including statistics, recent applications,
/// and profile status. Used to display the employee dashboard view.
///
/// This is a read-only data class aggregated from various API sources.
class EmployeeDashboardModel {
  // ======== STATISTICS ========
  final int totalApplications;
  final int applicationsUnderReview;
  final int acceptedOffers;
  final int rejectedApplications;

  // ======== RECENT ACTIVITY ========
  final List<EmployeeApplicationModel> recentApplications; // Max 5 most recent
  final List<EmployeeApplicationModel> recentRejections; // Max 3 most recent

  // ======== PROFILE STATUS ========
  final int profileCompletionPercentage; // 0-100
  final List<String> profileSuggestions; // Tips to improve profile

  /// Constructor with named parameters
  ///
  /// All parameters are required but can have default values
  EmployeeDashboardModel({
    required this.totalApplications,
    required this.applicationsUnderReview,
    required this.acceptedOffers,
    required this.rejectedApplications,
    required this.recentApplications,
    required this.recentRejections,
    required this.profileCompletionPercentage,
    required this.profileSuggestions,
  });

  /// Create from JSON (API response)
  ///
  /// Expected JSON format with nested "stats", "recentApplications",
  /// "recentRejections" objects and "profileCompletion" with percentage
  /// and suggestions array.
  factory EmployeeDashboardModel.fromJson(Map<String, dynamic> json) {
    // Parse stats section
    final stats = json['stats'] ?? {};
    final totalApplications = _parseInt(stats['totalApplications']) ?? 0;
    final applicationsUnderReview =
        _parseInt(stats['applicationsUnderReview']) ?? 0;
    final acceptedOffers = _parseInt(stats['acceptedOffers']) ?? 0;
    final rejectedApplications = _parseInt(stats['rejectedApplications']) ?? 0;

    // Parse recent applications
    final recentAppsJson = json['recentApplications'] as List? ?? [];
    final recentApplications =
        recentAppsJson
            .whereType<Map<String, dynamic>>()
            .map((app) => EmployeeApplicationModel.fromJson(app))
            .toList();

    // Parse recent rejections
    final recentRejJson = json['recentRejections'] as List? ?? [];
    final recentRejections =
        recentRejJson
            .whereType<Map<String, dynamic>>()
            .map((app) => EmployeeApplicationModel.fromJson(app))
            .toList();

    // Parse profile completion
    final profileCompletion = json['profileCompletion'] ?? {};
    final profileCompletionPercentage =
        _parseInt(profileCompletion['percentage']) ?? 0;
    final profileSuggestions = _parseStringList(
      profileCompletion['suggestions'],
    );

    return EmployeeDashboardModel(
      totalApplications: totalApplications,
      applicationsUnderReview: applicationsUnderReview,
      acceptedOffers: acceptedOffers,
      rejectedApplications: rejectedApplications,
      recentApplications: recentApplications,
      recentRejections: recentRejections,
      profileCompletionPercentage: profileCompletionPercentage,
      profileSuggestions: profileSuggestions,
    );
  }

  /// Convert to JSON (for API requests if needed)
  ///
  /// NOTE: Dashboard is typically read-only, but included for consistency
  Map<String, dynamic> toJson() {
    return {
      'stats': {
        'totalApplications': totalApplications,
        'applicationsUnderReview': applicationsUnderReview,
        'acceptedOffers': acceptedOffers,
        'rejectedApplications': rejectedApplications,
      },
      'recentApplications':
          recentApplications.map((app) => app.toJson()).toList(),
      'recentRejections': recentRejections.map((app) => app.toJson()).toList(),
      'profileCompletion': {
        'percentage': profileCompletionPercentage,
        'suggestions': profileSuggestions,
      },
    };
  }

  /// Create a copy with modified fields
  ///
  /// Useful for local state updates before API sync
  EmployeeDashboardModel copyWith({
    int? totalApplications,
    int? applicationsUnderReview,
    int? acceptedOffers,
    int? rejectedApplications,
    List<EmployeeApplicationModel>? recentApplications,
    List<EmployeeApplicationModel>? recentRejections,
    int? profileCompletionPercentage,
    List<String>? profileSuggestions,
  }) {
    return EmployeeDashboardModel(
      totalApplications: totalApplications ?? this.totalApplications,
      applicationsUnderReview:
          applicationsUnderReview ?? this.applicationsUnderReview,
      acceptedOffers: acceptedOffers ?? this.acceptedOffers,
      rejectedApplications: rejectedApplications ?? this.rejectedApplications,
      recentApplications: recentApplications ?? this.recentApplications,
      recentRejections: recentRejections ?? this.recentRejections,
      profileCompletionPercentage:
          profileCompletionPercentage ?? this.profileCompletionPercentage,
      profileSuggestions: profileSuggestions ?? this.profileSuggestions,
    );
  }

  /// Calculate application success rate as percentage
  ///
  /// Returns: (acceptedOffers / totalApplications) * 100, or 0 if no applications
  ///
  /// Example: 2 accepted out of 10 applications = 20%
  double applicationSuccessRate() {
    if (totalApplications == 0) return 0;
    return (acceptedOffers / totalApplications) * 100;
  }

  /// Check if dashboard has any data
  ///
  /// Returns: true if all stats are 0 and no recent applications
  bool get isEmpty =>
      totalApplications == 0 &&
      applicationsUnderReview == 0 &&
      acceptedOffers == 0 &&
      rejectedApplications == 0 &&
      recentApplications.isEmpty &&
      recentRejections.isEmpty;

  /// Get remaining applications (applied + under review)
  ///
  /// Useful for showing "pending" count
  int get pendingApplications =>
      totalApplications - acceptedOffers - rejectedApplications;

  /// Check if there are pending applications
  bool get hasPendingApplications => pendingApplications > 0;

  /// Check if there are accepted offers
  bool get hasAcceptedOffers => acceptedOffers > 0;

  /// Check if profile needs attention (< 50% complete)
  bool get needsProfileCompletion => profileCompletionPercentage < 50;

  /// Get most recent application (if any)
  EmployeeApplicationModel? get mostRecentApplication =>
      recentApplications.isNotEmpty ? recentApplications.first : null;

  /// Get notification count for dashboard badge
  ///
  /// Combines: under review count + accepted offers
  int get notificationCount => applicationsUnderReview + acceptedOffers;

  /// Format stats for display
  ///
  /// Returns a readable summary for dashboard cards
  Map<String, String> getFormattedStats() {
    return {
      'total': '$totalApplications',
      'underReview': '$applicationsUnderReview',
      'accepted': '$acceptedOffers',
      'rejected': '$rejectedApplications',
      'successRate': '${applicationSuccessRate().toStringAsFixed(1)}%',
      'profileCompletion': '$profileCompletionPercentage%',
    };
  }

  @override
  String toString() =>
      'EmployeeDashboardModel(total: $totalApplications, accepted: $acceptedOffers, underReview: $applicationsUnderReview, profileCompletion: $profileCompletionPercentage%)';

  // ======== HELPER FUNCTIONS ========

  /// Parse integer value safely
  ///
  /// [value] - Can be int, String, or null
  /// Returns: Parsed int or null if invalid
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse list of strings safely
  ///
  /// [value] - Can be List or null
  /// Returns: List of strings, empty list if invalid
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  /// Create empty dashboard (for initial state)
  ///
  /// Useful for providers when data hasn't loaded yet
  static EmployeeDashboardModel empty() {
    return EmployeeDashboardModel(
      totalApplications: 0,
      applicationsUnderReview: 0,
      acceptedOffers: 0,
      rejectedApplications: 0,
      recentApplications: [],
      recentRejections: [],
      profileCompletionPercentage: 0,
      profileSuggestions: [
        'Complete your profile to attract more opportunities',
      ],
    );
  }

  /// Create mock/dummy dashboard for testing/preview
  ///
  /// Useful for development and UI preview
  static EmployeeDashboardModel mock() {
    return EmployeeDashboardModel(
      totalApplications: 12,
      applicationsUnderReview: 3,
      acceptedOffers: 2,
      rejectedApplications: 5,
      recentApplications: [
        EmployeeApplicationModel(
          id: 'app_1',
          employeeId: 'emp_1',
          jobId: 'job_1',
          jobTitle: 'Senior Flutter Developer',
          companyName: 'Tech Corp',
          postedBy: 'Anand Kumar',
          status: ApplicationStatus.reviewing,
          appliedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        EmployeeApplicationModel(
          id: 'app_2',
          employeeId: 'emp_1',
          jobId: 'job_2',
          jobTitle: 'Full Stack Developer',
          companyName: 'Digital Solutions',
          postedBy: 'Priya Singh',
          status: ApplicationStatus.applied,
          appliedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      recentRejections: [
        EmployeeApplicationModel(
          id: 'app_3',
          employeeId: 'emp_1',
          jobId: 'job_3',
          jobTitle: 'Frontend Developer',
          companyName: 'Web Designs Inc',
          postedBy: 'John Doe',
          status: ApplicationStatus.rejected,
          appliedAt: DateTime.now().subtract(const Duration(days: 7)),
          rejectionReason: 'We found a more experienced candidate',
        ),
      ],
      profileCompletionPercentage: 75,
      profileSuggestions: [
        'Add more technical skills to your profile',
        'Consider uploading a professional headshot',
      ],
    );
  }
}
