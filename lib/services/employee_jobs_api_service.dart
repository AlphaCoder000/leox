import 'api_service.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/employee_application_model.dart';

/// Employee Jobs API Service
///
/// Handles all job-related API calls for employees:
/// - Browse and search jobs
/// - Apply to jobs
/// - Track applications
class EmployeeJobsApiService {
  /// Fetch all available jobs with pagination and filtering
  ///
  /// [page] - Page number (1-based), default 1
  /// [limit] - Items per page, default 20
  /// [department] - Filter by department (optional)
  /// [category] - Filter by job category (optional)
  /// [status] - Filter by job status: "open", "closed" (optional)
  /// [authToken] - Optional auth token for authenticated requests
  ///
  /// Returns: {jobs: [JobModel], total: int, page: int, pages: int}
  static Future<Map<String, dynamic>> getAllJobs({
    int page = 1,
    int limit = 20,
    String? department,
    String? category,
    String? status,
    String? authToken,
  }) async {
    try {
      // Build query string
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (department != null) 'department': department,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
      };

      // Build query string
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = '/jobs?$queryString';

      final response = await ApiService.get(endpoint, authToken: authToken);

      // Parse response
      final jobs =
          (response['jobs'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(
                (job) => JobModel(
                  title: job['title'] ?? 'Untitled',
                  department: job['department'] ?? 'Not specified',
                  category: job['category'] ?? 'Not specified',
                  description: job['description'] ?? '',
                  requirements: _parseStringList(job['requirements'] ?? []),
                  postedOn: _parseDateTime(job['postedOn']) ?? DateTime.now(),
                  candidates: const [],
                  status: job['status'] ?? 'Open',
                  postedBy: job['postedBy'] ?? 'Unknown',
                  companyName: job['companyName'],
                ),
              )
              .toList();

      return {
        'jobs': jobs,
        'total': response['total'] ?? 0,
        'page': response['page'] ?? 1,
        'pages': response['pages'] ?? 1,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Search jobs by query string
  ///
  /// [query] - Search query (matches title, department, description)
  /// [page] - Page number (1-based), default 1
  /// [limit] - Items per page, default 20
  /// [authToken] - Optional auth token for authenticated requests
  ///
  /// Returns: {jobs: [JobModel], total: int}
  static Future<Map<String, dynamic>> searchJobs({
    required String query,
    int page = 1,
    int limit = 20,
    String? authToken,
  }) async {
    try {
      // Build query string
      final params = {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = '/jobs/search?$queryString';

      final response = await ApiService.get(endpoint, authToken: authToken);

      // Parse response
      final jobs =
          (response['jobs'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(
                (job) => JobModel(
                  title: job['title'] ?? 'Untitled',
                  department: job['department'] ?? 'Not specified',
                  category: job['category'] ?? 'Not specified',
                  description: job['description'] ?? '',
                  requirements: _parseStringList(job['requirements'] ?? []),
                  postedOn: _parseDateTime(job['postedOn']) ?? DateTime.now(),
                  candidates: const [],
                  status: job['status'] ?? 'Open',
                  postedBy: job['postedBy'] ?? 'Unknown',
                  companyName: job['companyName'],
                ),
              )
              .toList();

      return {'jobs': jobs, 'total': response['total'] ?? 0};
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information about a specific job
  ///
  /// [jobId] - Job posting ID
  /// [authToken] - Optional auth token for authenticated requests
  ///
  /// Returns: JobModel with full details
  static Future<JobModel> getJobById({
    required String jobId,
    String? authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/jobs/$jobId',
        authToken: authToken,
      );

      return JobModel(
        title: response['title'] ?? 'Untitled',
        department: response['department'] ?? 'Not specified',
        category: response['category'] ?? 'Not specified',
        description: response['description'] ?? '',
        requirements: _parseStringList(response['requirements'] ?? []),
        postedOn: _parseDateTime(response['postedOn']) ?? DateTime.now(),
        candidates: const [],
        status: response['status'] ?? 'Open',
        postedBy: response['postedBy'] ?? 'Unknown',
        companyName: response['companyName'],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Apply to a job
  ///
  /// [jobId] - Job posting ID to apply to
  /// [coverLetter] - Optional cover letter text
  /// [authToken] - Auth token (required for application)
  ///
  /// Returns: {id, jobId, status, appliedAt, message}
  static Future<Map<String, dynamic>> applyToJob({
    required String jobId,
    String? coverLetter,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.post(
        '/jobs/$jobId/apply',
        body: {
          'jobId': jobId,
          if (coverLetter != null && coverLetter.isNotEmpty)
            'coverLetter': coverLetter,
        },
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all applications for the current employee
  ///
  /// [page] - Page number (1-based), default 1
  /// [limit] - Items per page, default 20
  /// [status] - Filter by application status: "applied", "reviewing", "offer", "accepted", "rejected", "withdrawn"
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {applications: [EmployeeApplicationModel], total: int, page: int}
  static Future<Map<String, dynamic>> getApplications({
    int page = 1,
    int limit = 20,
    String? status,
    required String authToken,
  }) async {
    try {
      // Build query string
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = '/employee/applications?$queryString';

      final response = await ApiService.get(endpoint, authToken: authToken);

      // Parse response
      final applications =
          (response['applications'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map((app) => EmployeeApplicationModel.fromJson(app))
              .toList();

      return {
        'applications': applications,
        'total': response['total'] ?? 0,
        'page': response['page'] ?? 1,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get status of a specific application
  ///
  /// [applicationId] - Application ID to check status for
  /// [authToken] - Auth token (required)
  ///
  /// Returns: EmployeeApplicationModel with current status
  static Future<EmployeeApplicationModel> getApplicationStatus({
    required String applicationId,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/applications/$applicationId',
        authToken: authToken,
      );

      return EmployeeApplicationModel.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Withdraw an application
  ///
  /// [applicationId] - Application ID to withdraw
  /// [reason] - Optional reason for withdrawal
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {id, status, message}
  static Future<Map<String, dynamic>> withdrawApplication({
    required String applicationId,
    String? reason,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.post(
        '/employee/applications/$applicationId/withdraw',
        body: {if (reason != null && reason.isNotEmpty) 'reason': reason},
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get job recommendations based on profile
  ///
  /// [limit] - Max number of recommendations, default 10
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {recommendations: [JobModel]}
  static Future<Map<String, dynamic>> getRecommendedJobs({
    int limit = 10,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/jobs/recommended?limit=$limit',
        authToken: authToken,
      );

      // Parse response
      final jobs =
          (response['jobs'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(
                (job) => JobModel(
                  title: job['title'] ?? 'Untitled',
                  department: job['department'] ?? 'Not specified',
                  category: job['category'] ?? 'Not specified',
                  description: job['description'] ?? '',
                  requirements: _parseStringList(job['requirements'] ?? []),
                  postedOn: _parseDateTime(job['postedOn']) ?? DateTime.now(),
                  candidates: const [],
                  status: job['status'] ?? 'Open',
                  postedBy: job['postedBy'] ?? 'Unknown',
                  companyName: job['companyName'],
                ),
              )
              .toList();

      return {'jobs': jobs};
    } catch (e) {
      rethrow;
    }
  }

  /// Save/bookmark a job for later viewing
  ///
  /// [jobId] - Job ID to save
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {jobId, saveId, message}
  static Future<Map<String, dynamic>> saveJob({
    required String jobId,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.post(
        '/employee/saved-jobs',
        body: {'jobId': jobId},
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a saved job
  ///
  /// [jobId] - Job ID to unsave
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {message}
  static Future<Map<String, dynamic>> unsaveJob({
    required String jobId,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.delete(
        '/employee/saved-jobs/$jobId',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get saved jobs list
  ///
  /// [page] - Page number (1-based), default 1
  /// [limit] - Items per page, default 20
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {jobs: [JobModel], total: int}
  static Future<Map<String, dynamic>> getSavedJobs({
    int page = 1,
    int limit = 20,
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/saved-jobs?page=$page&limit=$limit',
        authToken: authToken,
      );

      // Parse response
      final jobs =
          (response['jobs'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(
                (job) => JobModel(
                  title: job['title'] ?? 'Untitled',
                  department: job['department'] ?? 'Not specified',
                  category: job['category'] ?? 'Not specified',
                  description: job['description'] ?? '',
                  requirements: _parseStringList(job['requirements'] ?? []),
                  postedOn: _parseDateTime(job['postedOn']) ?? DateTime.now(),
                  candidates: const [],
                  status: job['status'] ?? 'Open',
                  postedBy: job['postedBy'] ?? 'Unknown',
                  companyName: job['companyName'],
                ),
              )
              .toList();

      return {'jobs': jobs, 'total': response['total'] ?? 0};
    } catch (e) {
      rethrow;
    }
  }

  // ======== HELPER FUNCTIONS ========

  /// Parse list of strings safely
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  /// Parse DateTime from ISO 8601 string
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('[EmployeeJobsApiService] Failed to parse date: $value');
        return null;
      }
    }
    return null;
  }
}
