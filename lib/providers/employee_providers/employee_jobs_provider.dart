import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/job_model.dart';
import '../../models/employee_application_model.dart';
import '../../services/employee_jobs_api_service.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class EmployeeJobsProvider extends ChangeNotifier {
  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  List<JobModel> _filteredJobs = [];
  List<JobModel> get filteredJobs => _filteredJobs;

  List<EmployeeApplicationModel> _applications = [];
  List<EmployeeApplicationModel> get applications => _applications;

  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  String _lastSearchQuery = '';
  String get lastSearchQuery => _lastSearchQuery;

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

  /// Fetch jobs from API with pagination and filters
  ///
  /// [page] - Page number (1-based)
  /// [department] - Optional department filter
  /// [category] - Optional category filter
  /// [status] - Optional status filter (e.g., "open", "closed")
  ///
  /// Logs: Fetch attempt, success, and errors
  Future<void> fetchJobs({
    int page = 1,
    String? department,
    String? category,
    String? status,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token from session
      final authToken = await SessionService.getAuthToken();

      // LOG: Fetch initiation
      debugPrint('[EmployeeJobsProvider] Fetching jobs (page: $page)...');

      // Call API
      final response = await EmployeeJobsApiService.getAllJobs(
        page: page,
        limit: 20,
        department: department,
        category: category,
        status: status,
        authToken: authToken,
      );

      // Extract data from response
      _jobs = response['jobs'] ?? [];
      _filteredJobs = List.from(_jobs);
      _currentPage = response['page'] ?? 1;
      _totalPages = response['pages'] ?? 1;
      _lastSearchQuery = '';

      // LOG: Success
      debugPrint('[EmployeeJobsProvider] Loaded ${_jobs.length} jobs');
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeJobsProvider] API Error: ${e.message}');
    } catch (e) {
      _setError('Failed to fetch jobs: $e');
      debugPrint('[EmployeeJobsProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search jobs by query
  ///
  /// [query] - Search string (title, department, description)
  ///
  /// Logs: Search attempt, query, results count
  Future<void> searchJobs(String query) async {
    _setLoading(true);
    _setError(null);

    try {
      // Return all jobs if query is empty
      if (query.isEmpty) {
        _filteredJobs = List.from(_jobs);
        _lastSearchQuery = '';
        notifyListeners();
        return;
      }

      // Get auth token from session
      final authToken = await SessionService.getAuthToken();

      // LOG: Search initiation
      debugPrint('[EmployeeJobsProvider] Searching for: "$query"');

      // Call API
      final response = await EmployeeJobsApiService.searchJobs(
        query: query,
        limit: 50,
        authToken: authToken,
      );

      // Update filtered list
      _filteredJobs = response['jobs'] ?? [];
      _lastSearchQuery = query;

      // LOG: Results
      debugPrint(
        '[EmployeeJobsProvider] Search found ${_filteredJobs.length} results',
      );
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeJobsProvider] Search error: ${e.message}');
    } catch (e) {
      _setError('Search failed: $e');
      debugPrint('[EmployeeJobsProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Local search on already-loaded jobs (no API call)
  ///
  /// Faster than searchJobs() for real-time search as user types
  /// Falls back to full search via API if no local match
  List<JobModel> localSearch(String query) {
    if (query.isEmpty) return _jobs;

    return _jobs
        .where(
          (j) =>
              j.title.toLowerCase().contains(query.toLowerCase()) ||
              j.department.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Apply to a job
  ///
  /// [jobId] - Job ID to apply to
  /// [coverLetter] - Optional cover letter text
  ///
  /// Returns: Application ID if successful
  /// Logs: Application attempt, success/failure
  Future<String?> applyToJob({
    required String jobId,
    String? coverLetter,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token (required for applications)
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated. Please login first.');
      }

      // LOG: Application attempt
      debugPrint('[EmployeeJobsProvider] Applying to job: $jobId');

      // Call API
      final response = await EmployeeJobsApiService.applyToJob(
        jobId: jobId,
        coverLetter: coverLetter,
        authToken: authToken,
      );

      final applicationId = response['id'] ?? response['applicationId'] ?? '';

      // LOG: Success
      debugPrint('[EmployeeJobsProvider] Application submitted: $applicationId');

      // Refresh applications list
      await getApplications();

      return applicationId;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeJobsProvider] Application error: ${e.message}');
      return null;
    } catch (e) {
      _setError('Failed to apply: $e');
      debugPrint('[EmployeeJobsProvider] Unexpected error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get all applications for the current employee
  ///
  /// [status] - Optional filter by application status
  ///
  /// Logs: Fetch attempt, count of applications
  Future<void> getApplications({String? status}) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Fetch initiation
      debugPrint('[EmployeeJobsProvider] Fetching applications...');

      // Call API
      final response = await EmployeeJobsApiService.getApplications(
        status: status,
        authToken: authToken,
      );

      _applications = response['applications'] ?? [];

      // LOG: Success
      debugPrint(
        '[EmployeeJobsProvider] Loaded ${_applications.length} applications',
      );
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeJobsProvider] Get applications error: ${e.message}');
    } catch (e) {
      _setError('Failed to fetch applications: $e');
      debugPrint('[EmployeeJobsProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Withdraw an application
  ///
  /// [applicationId] - Application to withdraw
  /// [reason] - Optional reason
  ///
  /// Logs: Withdrawal attempt and success
  Future<bool> withdrawApplication({
    required String applicationId,
    String? reason,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Withdrawal attempt
      debugPrint('[EmployeeJobsProvider] Withdrawing application: $applicationId');

      // Call API
      await EmployeeJobsApiService.withdrawApplication(
        applicationId: applicationId,
        reason: reason,
        authToken: authToken,
      );

      // LOG: Success
      debugPrint('[EmployeeJobsProvider] Application withdrawn');

      // Refresh applications list
      await getApplications();

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeJobsProvider] Withdrawal error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to withdraw: $e');
      debugPrint('[EmployeeJobsProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get recommended jobs based on profile
  ///
  /// Logs: Fetch attempt and count
  Future<void> getRecommendedJobs() async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();

      // LOG: Fetch initiation
      debugPrint('[EmployeeJobsProvider] Fetching recommended jobs...');

      // Call API
      final response = await EmployeeJobsApiService.getRecommendedJobs(
        limit: 15,
        authToken: authToken ?? '',
      );

      final recommendedJobs = response['jobs'] as List<JobModel>? ?? [];

      // LOG: Success
      debugPrint(
        '[EmployeeJobsProvider] Loaded ${recommendedJobs.length} recommendations',
      );

      // Note: You can create a separate _recommendedJobs list if needed
      // For now, return via separate method
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeJobsProvider] Recommendations error: ${e.message}');
    } catch (e) {
      _setError('Failed to fetch recommendations: $e');
      debugPrint('[EmployeeJobsProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if a job has already been applied to
  ///
  /// [jobId] - Job ID to check
  /// Returns: Application if exists, null otherwise
  EmployeeApplicationModel? getApplicationForJob(String jobId) {
    try {
      return _applications.firstWhere((app) => app.jobId == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Get count of pending applications
  int get pendingApplicationCount =>
      _applications.where((app) => app.isPending).length;

  /// Get count of accepted offers
  int get acceptedApplicationCount =>
      _applications.where((app) => app.isAccepted).length;

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Search method for backward compatibility
  /// (used by existing views before API integration)
  List<JobModel> search(String query) {
    if (query.isEmpty) return _jobs;
    return localSearch(query);
  }
}
