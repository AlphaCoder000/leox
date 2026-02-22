import 'package:flutter/material.dart';

/// Application Status Enum
///
/// Represents the different states of a job application
enum ApplicationStatus {
  applied,
  reviewing,
  rejected,
  offer,
  accepted,
  withdrawn,
}

/// Extension to convert string to ApplicationStatus
extension ApplicationStatusExtension on String {
  ApplicationStatus toApplicationStatus() {
    switch (toLowerCase()) {
      case 'reviewing':
        return ApplicationStatus.reviewing;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'offer':
        return ApplicationStatus.offer;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.applied;
    }
  }
}

/// Extension to get string representation
extension ApplicationStatusString on ApplicationStatus {
  String get value {
    switch (this) {
      case ApplicationStatus.applied:
        return 'applied';
      case ApplicationStatus.reviewing:
        return 'reviewing';
      case ApplicationStatus.rejected:
        return 'rejected';
      case ApplicationStatus.offer:
        return 'offer';
      case ApplicationStatus.accepted:
        return 'accepted';
      case ApplicationStatus.withdrawn:
        return 'withdrawn';
    }
  }
}

/// Employee Job Application Model
///
/// Represents an employee's application to a job posting.
/// Contains both reference IDs and denormalized data for efficient display.
///
/// Separate from JobModel because it tracks application-specific data
/// (status, cover letter, dates) which don't belong on the job itself.
class EmployeeApplicationModel {
  // ======== REFERENCE IDs ========
  final String id; // Application ID
  final String employeeId; // Who is applying
  final String jobId; // Which job posting

  // ======== DENORMALIZED JOB DATA (for display without extra API calls) ========
  final String jobTitle; // To show in app list
  final String companyName; // Employer company
  final String postedBy; // Employer name (e.g., "Anand Kumar")

  // ======== APPLICATION SPECIFIC DATA ========
  final ApplicationStatus status; // Current status of application
  final String? coverLetter; // Optional message from applicant
  final DateTime appliedAt; // When the application was submitted
  final DateTime? updatedAt; // Last update (for status changes)

  // ======== OPTIONAL FIELDS ========
  final String? interviewDate; // If status = offer/accepted
  final String? rejectionReason; // If status = rejected
  final int? matchScore; // AI-calculated match score (0-100) if available

  /// Constructor with named parameters
  EmployeeApplicationModel({
    required this.id,
    required this.employeeId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.postedBy,
    required this.status,
    required this.appliedAt,
    this.coverLetter,
    this.updatedAt,
    this.interviewDate,
    this.rejectionReason,
    this.matchScore,
  });

  /// Create from JSON (API response)
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": "app_123",
  ///   "employeeId": "emp_456",
  ///   "jobId": "job_789",
  ///   "jobTitle": "Senior Flutter Developer",
  ///   "companyName": "Tech Corp",
  ///   "postedBy": "Anand Kumar",
  ///   "status": "reviewing",
  ///   "coverLetter": "I'm very interested in this role...",
  ///   "appliedAt": "2025-01-15T10:30:00Z",
  ///   "updatedAt": "2025-01-18T14:45:00Z",
  ///   "interviewDate": "2025-02-01",
  ///   "rejectionReason": null,
  ///   "matchScore": 85
  /// }
  /// ```
  factory EmployeeApplicationModel.fromJson(Map<String, dynamic> json) {
    return EmployeeApplicationModel(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      jobId: json['jobId'] ?? '',
      jobTitle: json['jobTitle'] ?? 'Untitled Job',
      companyName: json['companyName'] ?? 'Unknown Company',
      postedBy: json['postedBy'] ?? 'Unknown',
      status: (json['status'] as String? ?? 'applied').toApplicationStatus(),
      appliedAt: _parseDateTime(json['appliedAt']) ?? DateTime.now(),
      coverLetter: json['coverLetter'],
      updatedAt: _parseDateTime(json['updatedAt']),
      interviewDate: json['interviewDate'],
      rejectionReason: json['rejectionReason'],
      matchScore: _parseInt(json['matchScore']),
    );
  }

  /// Convert to JSON (for API requests)
  ///
  /// NOTE: Only includes fields that should be sent to server
  /// (excludes id, appliedAt, updatedAt which are server-managed)
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'postedBy': postedBy,
      'status': status.value,
      if (coverLetter != null) 'coverLetter': coverLetter,
      if (interviewDate != null) 'interviewDate': interviewDate,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  /// Create a copy with modified fields
  ///
  /// Useful for local state updates (e.g., status change before API sync)
  EmployeeApplicationModel copyWith({
    String? id,
    String? employeeId,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? postedBy,
    ApplicationStatus? status,
    String? coverLetter,
    DateTime? appliedAt,
    DateTime? updatedAt,
    String? interviewDate,
    String? rejectionReason,
    int? matchScore,
  }) {
    return EmployeeApplicationModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      postedBy: postedBy ?? this.postedBy,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      interviewDate: interviewDate ?? this.interviewDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  /// Get color for status display in UI
  ///
  /// Returns appropriate Material color for status badge/chip
  Color statusColor() {
    switch (status) {
      case ApplicationStatus.applied:
        return Colors.grey[600]!; // Neutral gray
      case ApplicationStatus.reviewing:
        return Colors.blue[600]!; // Primary blue
      case ApplicationStatus.rejected:
        return Colors.red[600]!; // Red for rejected
      case ApplicationStatus.offer:
        return Colors.orange[600]!; // Orange for pending decision
      case ApplicationStatus.accepted:
        return Colors.green[600]!; // Green for success
      case ApplicationStatus.withdrawn:
        return Colors.grey[500]!; // Dimmed gray
    }
  }

  /// Get readable status label for UI
  ///
  /// Returns: "Applied", "Under Review", "Rejected", etc.
  String statusLabel() {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.reviewing:
        return 'Under Review';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.offer:
        return 'Offer Received';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  /// Get icon for status display
  ///
  /// Returns: IconData for appropriate Material icon
  IconData statusIcon() {
    switch (status) {
      case ApplicationStatus.applied:
        return Icons.check_circle_outline;
      case ApplicationStatus.reviewing:
        return Icons.visibility_outlined;
      case ApplicationStatus.rejected:
        return Icons.cancel_outlined;
      case ApplicationStatus.offer:
        return Icons.card_giftcard_outlined;
      case ApplicationStatus.accepted:
        return Icons.verified_outlined;
      case ApplicationStatus.withdrawn:
        return Icons.close_outlined;
    }
  }

  /// Check if application is still active (not rejected/withdrawn)
  bool get isActive =>
      status != ApplicationStatus.rejected &&
      status != ApplicationStatus.withdrawn;

  /// Check if application has been accepted
  bool get isAccepted => status == ApplicationStatus.accepted;

  /// Check if application is pending (waiting for response)
  bool get isPending =>
      status == ApplicationStatus.applied ||
      status == ApplicationStatus.reviewing;

  /// Days since application was submitted
  int get daysSinceApplied => DateTime.now().difference(appliedAt).inDays;

  /// Format status with display count (e.g., "Under Review (3+ days)")
  String statusWithDays() {
    if (isPending) {
      return '${statusLabel()} ($daysSinceApplied+ days)';
    }
    if (updatedAt != null) {
      final daysSinceUpdate = DateTime.now().difference(updatedAt!).inDays;
      return '${statusLabel()} ($daysSinceUpdate days ago)';
    }
    return statusLabel();
  }

  @override
  String toString() =>
      'EmployeeApplicationModel(jobTitle: $jobTitle, status: ${status.value}, appliedAt: $appliedAt)';

  // ======== HELPER FUNCTIONS ========

  /// Parse DateTime from ISO 8601 string
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('[EmployeeApplicationModel] Failed to parse date: $value');
        return null;
      }
    }
    return null;
  }

  /// Parse integer value safely
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
