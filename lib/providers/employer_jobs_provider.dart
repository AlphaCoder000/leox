import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:leox/services/firebase_service.dart';

class EmployerJobsProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  final FirebaseService _firebaseService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployerJobsProvider({FirebaseService? firebaseService}) 
      : _firebaseService = firebaseService ?? FirebaseService();

  // ================= PRIVATE =================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ================= LOAD =================

  Future<void> loadJobs() async {
    _setLoading(true);
    _setError(null);

    try {
      final jobs = await _firebaseService.getEmployerJobs();
      _jobs = List.from(jobs);
      debugPrint('[EmployerJobsProvider] Loaded ${jobs.length} jobs from Firebase');
    } catch (e) {
      debugPrint('[EmployerJobsProvider] Firebase error: $e');
      _setError('Failed to load jobs: ${e.toString()}');
      // Don't use dummy data - keep empty list to show real Firebase state
      _jobs = [];
    } finally {
      _setLoading(false);
    }
  }

  // ================= ADD =================

  Future<void> addJob(JobModel job) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.postJob(job);
      _jobs.insert(0, job);
      notifyListeners();
      debugPrint('[EmployerJobsProvider] Job added to Firebase: ${job.title}');
    } catch (e) {
      debugPrint('[EmployerJobsProvider] Firebase error: $e');
      _setError('Failed to post job: ${e.toString()}');
      rethrow; // Rethrow so UI knows it failed
    } finally {
      _setLoading(false);
    }
  }

  // ================= DELETE =================

  Future<void> deleteJob(JobModel job) async {
    _setLoading(true);
    _setError(null);

    try {
      // For now, use a simple approach - in real implementation, you'd store job ID
      // This is a simplified version for demo purposes
      await _firebaseService.deleteJob(job.id);
      _jobs.remove(job);
      notifyListeners();
      debugPrint('[EmployerJobsProvider] Job deleted: ${job.title}');
    } catch (e) {
      _setError('Failed to delete job: $e');
      debugPrint('[EmployerJobsProvider] Error deleting job: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ================= UPDATE =================

  Future<void> updateJob(JobModel oldJob, JobModel updatedJob) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.updateJob(updatedJob);

      final index =
          _jobs.indexWhere((job) => job.id == updatedJob.id);

      if (index != -1) {
        _jobs[index] = updatedJob;
      }

      debugPrint('[EmployerJobsProvider] Job updated: ${updatedJob.title}');
    } catch (e) {
      _setError('Failed to update job: $e');
      debugPrint('[EmployerJobsProvider] Error updating job: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ================= HELPERS =================

  void clearError() {
    _setError(null);
  }
}
