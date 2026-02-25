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

  /// Load dashboard data from Firestore
  Future<void> loadDashboard() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return;
      }

      // Load jobs count
      final jobsSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('employerId', isEqualTo: user.uid)
          .get();
      
      // Load applications count from employer's subcollection (Web App style)
      final applicationsSnapshot = await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .collection('applications')
          .get();

      // Calculate statistics
      totalJobs = jobsSnapshot.docs.length;
      totalCandidates = applicationsSnapshot.docs.length;
      
      // Count by status from the subcollection
      shortlisted = applicationsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'shortlisted')
          .length;
      
      hired = applicationsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'hired')
          .length;
      
      reviewed = applicationsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'reviewed')
          .length;
      
      rejected = applicationsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'rejected')
          .length;
      
      pending = applicationsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      debugPrint('[EmployerDashboardProvider] Dashboard loaded from subcollections: '
            'jobs=$totalJobs, candidates=$totalCandidates');

    } catch (e) {
      debugPrint('[EmployerDashboardProvider] Error loading dashboard: $e');
      _setError('Failed to load dashboard data');
    } finally {
      _setLoading(false);
    }
  }

  // ======== HELPERS ========

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }
}
