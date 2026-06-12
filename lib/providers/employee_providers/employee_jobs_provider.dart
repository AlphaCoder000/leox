import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/job_model.dart';

class EmployeeJobsProvider extends ChangeNotifier {
  final List<JobModel> _jobs = [];
  StreamSubscription<QuerySnapshot>? _jobsSubscription;

  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployeeJobsProvider();

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

  /// Load available jobs from Firebase in real-time
  Future<void> loadJobs() async {
    _setError(null);
    _jobsSubscription?.cancel();
    _setLoading(true);

    _jobsSubscription = FirebaseFirestore.instance
        .collection('jobs')
        .where('status', isEqualTo: 'Open')
        .snapshots()
        .listen((snapshot) {
      _jobs.clear();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return JobModel(
          id: doc.id,
          title: data['title'] ?? '',
          department: data['department'] ?? '',
          category: data['category'] ?? '',
          description: data['description'] ?? '',
          requirements: List<String>.from(data['requirements'] ?? []),
          postedOn: (data['postedOn'] as Timestamp?)?.toDate() ?? DateTime.now(),
          employerId: data['employerId'] ?? '',
          companyName: data['companyName'] ?? '',
          location: data['location'] ?? '',
          jobType: data['jobType'] ?? '',
          experienceLevel: data['experienceLevel'] ?? '',
          salaryRange: data['salaryRange'] ?? '',
          skills: List<String>.from(data['skills'] ?? []),
          benefits: List<String>.from(data['benefits'] ?? []),
          status: data['status'] ?? '',
          postedBy: data['postedBy'] ?? '',
          applicationCount: data['applicationCount'] ?? 0,
          deadline: (data['deadline'] as Timestamp?)?.toDate(),
          additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
        );
      }).toList();

      // Sort in-memory to avoid index requirement
      list.sort((a, b) => b.postedOn.compareTo(a.postedOn));
      _jobs.addAll(list);
      _setLoading(false);
      notifyListeners();
      debugPrint('[EmployeeJobsProvider] Real-time updated: ${_jobs.length} jobs');
    }, onError: (e) {
      debugPrint('[EmployeeJobsProvider] Error in stream: $e');
      _setError('Failed to load jobs: ${e.toString()}');
      _setLoading(false);
    });
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

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }
}
