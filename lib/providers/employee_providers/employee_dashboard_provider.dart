import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/employee_dashboard_model.dart';

class EmployeeDashboardProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployeeDashboardModel _dashboard = EmployeeDashboardModel.empty();
  EmployeeDashboardModel get dashboard => _dashboard;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

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

  /// Load dashboard data from Firebase
  Future<void> loadDashboard() async {
    // Check if user is authenticated before proceeding
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[EmployeeDashboardProvider] User not authenticated, skipping dashboard load');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {

      // Get user profile data from Firebase
      final userDoc = await _firestore.collection('employees').doc(user.uid).get();
      
      if (!userDoc.exists) {
        throw Exception('Employee profile not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get application statistics
      final applicationsSnapshot = await _firestore
          .collection('job_applications')
          .where('employeeId', isEqualTo: user.uid)
          .get();

      final applications = applicationsSnapshot.docs;
      
      // Calculate real statistics based on application status
      int totalApplications = applications.length;
      int applicationsUnderReview = 0;
      int acceptedOffers = 0;
      int rejectedApplications = 0;
      
      for (var doc in applications) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'pending';
        
        switch (status) {
          case 'pending':
          case 'reviewed':
            applicationsUnderReview++;
            break;
          case 'hired':
            acceptedOffers++;
            break;
          case 'rejected':
            rejectedApplications++;
            break;
        }
      }
      
      // Calculate profile completion from user data
      final profileCompletion = _calculateProfileCompletionFromUserData(userData);
      
      // Update dashboard model
      _dashboard = EmployeeDashboardModel(
        totalApplications: totalApplications,
        applicationsUnderReview: applicationsUnderReview,
        acceptedOffers: acceptedOffers,
        rejectedApplications: rejectedApplications,
        recentApplications: [], // Simplified - in real app, fetch recent applications
        recentRejections: [], // Simplified - in real app, fetch recent rejections
        profileCompletionPercentage: (profileCompletion * 100).round(),
        profileSuggestions: [], // Simplified - in real app, generate suggestions
      );

      _lastUpdated = DateTime.now();
      debugPrint('[EmployeeDashboardProvider] Dashboard loaded successfully');
    } catch (e) {
      debugPrint('[EmployeeDashboardProvider] Error loading dashboard: $e');
      _setError('Failed to load dashboard: ${e.toString()}');
      
      // Set empty dashboard on error
      _dashboard = EmployeeDashboardModel.empty();
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate profile completion percentage from user data
  double _calculateProfileCompletionFromUserData(Map<String, dynamic> userData) {
    int completedFields = 0;
    int totalFields = 6; // firstName, lastName, email, phone, bio, skills, resume

    if (userData['firstName'] != null && userData['firstName'].toString().isNotEmpty) completedFields++;
    if (userData['lastName'] != null && userData['lastName'].toString().isNotEmpty) completedFields++;
    if (userData['email'] != null && userData['email'].toString().isNotEmpty) completedFields++;
    if (userData['bio'] != null && userData['bio'].toString().isNotEmpty) completedFields++;
    if (userData['skills'] != null && userData['skills'].toString().isNotEmpty) completedFields++;
    if (userData['resumeUrl'] != null && userData['resumeUrl'].toString().isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }
}
