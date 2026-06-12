import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:leox/services/firebase_service.dart';

class EmployerJobsProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  final FirebaseService _firebaseService;
  StreamSubscription<QuerySnapshot>? _jobsSubscription;

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
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    _setError(null);
    _jobsSubscription?.cancel();
    _setLoading(true);

    _jobsSubscription = FirebaseFirestore.instance
        .collection('jobs')
        .where('postedBy', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
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
          employerId: data['employerId'] ?? data['postedBy'] ?? '',
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

      list.sort((a, b) => b.postedOn.compareTo(a.postedOn));
      _jobs = list;
      _setLoading(false);
      notifyListeners();
      debugPrint('[EmployerJobsProvider] Real-time updated: ${_jobs.length} jobs');
    }, onError: (e) {
      debugPrint('[EmployerJobsProvider] Error in stream: $e');
      _setError('Failed to load jobs: ${e.toString()}');
      _setLoading(false);
    });
  }

  // ================= ADD =================

  Future<void> addJob(JobModel job) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.postJob(job);
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
      await _firebaseService.deleteJob(job.id);
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

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }
}
