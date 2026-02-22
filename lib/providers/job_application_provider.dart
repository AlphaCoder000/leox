/// Job Application Provider
///
/// Manages job application state and operations
library;
import 'package:flutter/foundation.dart';
import '../models/job_application_model.dart';
import '../models/job_posting_model.dart';
import '../services/job_application_service.dart';

class JobApplicationProvider extends ChangeNotifier {
  final JobApplicationService _applicationService = JobApplicationService();

  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<JobApplicationModel> _applications = [];
  List<JobApplicationModel> get applications => _applications;

  Map<String, int> _applicationStats = {};
  Map<String, int> get applicationStats => _applicationStats;

  JobApplicationModel? _selectedApplication;
  JobApplicationModel? get selectedApplication => _selectedApplication;

  // ======== PRIVATE METHODS ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ======== PUBLIC METHODS ========

  /// Submit a job application
  Future<bool> submitApplication({
    required String jobId,
    required String coverLetter,
    required dynamic resumeFile,
    required JobPostingModel jobPosting,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('[JobApplicationProvider] Submitting application for job: $jobId');

      final applicationId = await _applicationService.submitApplication(
        jobId: jobId,
        coverLetter: coverLetter,
        resumeFile: resumeFile,
        jobPosting: jobPosting,
      );

      if (applicationId != null) {
        _setSuccess('Application submitted successfully!');
        
        // Refresh applications list if employee
        await loadEmployeeApplications();
        
        return true;
      }
      
      throw Exception('Failed to submit application');
    } catch (e) {
      _setError('Failed to submit application: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load all applications for employer
  Future<void> loadEmployerApplications() async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('[JobApplicationProvider] Loading employer applications');
      
      _applications = await _applicationService.getEmployerApplications();
      _applicationStats = await _applicationService.getEmployerApplicationStats();
      
      debugPrint('[JobApplicationProvider] Loaded ${_applications.length} applications');
    } catch (e) {
      _setError('Failed to load applications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load applications for specific job
  Future<void> loadJobApplications(String jobId) async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('[JobApplicationProvider] Loading applications for job: $jobId');
      
      _applications = await _applicationService.getJobApplications(jobId);
      
      debugPrint('[JobApplicationProvider] Loaded ${_applications.length} applications for job $jobId');
    } catch (e) {
      _setError('Failed to load job applications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load applications submitted by current employee
  Future<void> loadEmployeeApplications() async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('[JobApplicationProvider] Loading employee applications');
      
      _applications = await _applicationService.getEmployeeApplications();
      
      debugPrint('[JobApplicationProvider] Loaded ${_applications.length} employee applications');
    } catch (e) {
      _setError('Failed to load your applications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update application status
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('[JobApplicationProvider] Updating application status: $applicationId -> $status');

      final success = await _applicationService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
        notes: notes,
      );

      if (success) {
        _setSuccess('Application status updated successfully');
        
        // Refresh applications list
        await loadEmployerApplications();
        
        return true;
      }
      
      throw Exception('Failed to update application status');
    } catch (e) {
      _setError('Failed to update application status: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get application by ID
  Future<JobApplicationModel?> getApplicationById(String applicationId) async {
    try {
      debugPrint('[JobApplicationProvider] Getting application: $applicationId');
      
      _selectedApplication = await _applicationService.getApplicationById(applicationId);
      notifyListeners();
      
      return _selectedApplication;
    } catch (e) {
      _setError('Failed to get application: ${e.toString()}');
      return null;
    }
  }

  /// Delete application
  Future<bool> deleteApplication(String applicationId) async {
    _setLoading(true);
    _setError(null);

    try {
      debugPrint('[JobApplicationProvider] Deleting application: $applicationId');

      final success = await _applicationService.deleteApplication(applicationId);

      if (success) {
        _setSuccess('Application deleted successfully');
        
        // Remove from local list
        _applications.removeWhere((app) => app.id == applicationId);
        notifyListeners();
        
        return true;
      }
      
      throw Exception('Failed to delete application');
    } catch (e) {
      _setError('Failed to delete application: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Filter applications by status
  List<JobApplicationModel> getApplicationsByStatus(String status) {
    if (status == 'all') return _applications;
    return _applications.where((app) => app.status == status).toList();
  }

  /// Get applications count by status
  int getApplicationCountByStatus(String status) {
    if (status == 'all') return _applications.length;
    return _applications.where((app) => app.status == status).length;
  }

  /// Select application for detailed view
  void selectApplication(JobApplicationModel? application) {
    _selectedApplication = application;
    notifyListeners();
  }

  /// Clear selected application
  void clearSelectedApplication() {
    _selectedApplication = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _applications = [];
    _applicationStats = {};
    _selectedApplication = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
