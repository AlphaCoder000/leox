import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/job_model.dart';
import '../../services/firebase_service.dart';

class EmployeeJobsProvider extends ChangeNotifier {
  final List<JobModel> _jobs = [];
  final FirebaseService _firebaseService;

  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployeeJobsProvider() : _firebaseService = FirebaseService();

  List<JobModel> get jobs => _jobs;

  // ======== PRIVATE METHODS ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Load available jobs from Firebase
  Future<void> loadJobs() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _jobs.clear();
      final jobs = await _firebaseService.getAllJobs();
      _jobs.addAll(jobs);
      notifyListeners();
      debugPrint('[EmployeeJobsProvider] Loaded ${jobs.length} jobs from Firebase');
    } catch (e) {
      debugPrint('[EmployeeJobsProvider] Error loading jobs: $e');
      _setError('Failed to load jobs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get jobs by category
  List<JobModel> getJobsByCategory(String category) {
    return _jobs.where((job) => job.category == category).toList();
  }

  /// Get jobs by search term
  List<JobModel> searchJobs(String query) {
    if (query.isEmpty) return _jobs;
    
    final lowerQuery = query.toLowerCase();
    return _jobs.where((job) {
      return job.title.toLowerCase().contains(lowerQuery) ||
             job.description.toLowerCase().contains(lowerQuery) ||
             job.companyName.toLowerCase().contains(lowerQuery) ||
             job.skills.any((skill) => skill.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get job by ID
  JobModel? getJobById(String jobId) {
    try {
      return _jobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Save job for later viewing
  void saveJob(JobModel job) {
    if (!_jobs.any((j) => j.title == job.title)) {
      _jobs.add(job);
      notifyListeners();
      debugPrint('[EmployeeJobsProvider] Job saved: ${job.title}');
    }
  }

  /// Remove saved job
  void removeSavedJob(JobModel job) {
    _jobs.removeWhere((j) => j.title == job.title);
    notifyListeners();
    debugPrint('[EmployeeJobsProvider] Job removed: ${job.title}');
  }

  /// Get saved jobs
  List<JobModel> get savedJobs {
    return _jobs.where((job) => job.deadline != null).toList();
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }
}
