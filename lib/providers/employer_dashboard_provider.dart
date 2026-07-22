import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployerDashboardProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int totalJobs = 0;
  int totalCandidates = 0;
  int shortlisted = 0;
  int hired = 0;
  int reviewed = 0;
  int rejected = 0;
  int pending = 0;

  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stream Subscriptions for real-time sync
  StreamSubscription? _jobsSubscription;
  StreamSubscription? _appsSubscription;

  // ======== PRIVATE METHODS ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ======== DATA LOADING METHODS ========

  /// Setup real-time listeners for dashboard statistics
  void initializeDashboardListeners() {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return;
    }

    // Cancel existing subscriptions if any
    _jobsSubscription?.cancel();
    _appsSubscription?.cancel();

    _setLoading(true);
    _setError(null);

    // 1. Listen to jobs count in real-time
    _jobsSubscription = FirebaseFirestore.instance
        .collection('jobs')
        .where('employerId', isEqualTo: user.uid)
        .snapshots()
        .listen((jobsSnapshot) {
      totalJobs = jobsSnapshot.docs.length;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[EmployerDashboardProvider] Jobs stream error: $e');
      _setError('Failed to sync jobs count');
    });

    // 2. Listen to applications count and statuses in real-time
    _appsSubscription = FirebaseFirestore.instance
        .collection('employers')
        .doc(user.uid)
        .collection('applications')
        .snapshots()
        .listen((appsSnapshot) {
      totalCandidates = appsSnapshot.docs.length;
      
      // Count by status from the subcollection
      shortlisted = appsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'shortlisted')
          .length;
      
      hired = appsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'hired')
          .length;
      
      reviewed = appsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'reviewed')
          .length;
      
      rejected = appsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'rejected')
          .length;
      
      pending = appsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      notifyListeners();
      _setLoading(false);
    }, onError: (e) {
      debugPrint('[EmployerDashboardProvider] Applications stream error: $e');
      _setError('Failed to sync applications stats');
      _setLoading(false);
    });
  }

  /// Load dashboard data (migrated to real-time initialization)
  Future<void> loadDashboard() async {
    initializeDashboardListeners();
  }

  // ======== HELPERS ========

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    initializeDashboardListeners();
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    _appsSubscription?.cancel();
    super.dispose();
  }
}
