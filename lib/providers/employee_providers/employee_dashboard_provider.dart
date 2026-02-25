import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/employee_dashboard_model.dart';
import '../../models/job_application_model.dart';
import '../../models/employee_application_model.dart';

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
        debugPrint('[EmployeeDashboardProvider] Profile not found for ${user.uid}, showing empty dashboard');
        _dashboard = EmployeeDashboardModel.empty();
        _lastUpdated = DateTime.now();
        notifyListeners();
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get application statistics from employee's subcollection
      final applicationsSnapshot = await _firestore
          .collection('employees')
          .doc(user.uid)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();

      final applications = applicationsSnapshot.docs;
      
      // Calculate real statistics based on application status
      int totalApplications = applications.length;
      int applicationsUnderReview = 0;
      int acceptedOffers = 0;
      int rejectedApplications = 0;
      
      List<EmployeeApplicationModel> recentApplicationsList = [];
      List<EmployeeApplicationModel> recentRejectionsList = [];

      for (var doc in applications) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'pending';
        
        // Convert Firestore data to JobApplicationModel first (it's what we usually store)
        // then convert to EmployeeApplicationModel for dashboard compatibility
        final jobApp = JobApplicationModel.fromFirestore(doc);
        final empApp = _convertToEmployeeApp(jobApp);

        if (recentApplicationsList.length < 5) {
          recentApplicationsList.add(empApp);
        }

        switch (status) {
          case 'pending':
          case 'reviewed':
          case 'shortlisted':
            applicationsUnderReview++;
            break;
          case 'hired':
            acceptedOffers++;
            break;
          case 'rejected':
            rejectedApplications++;
            if (recentRejectionsList.length < 3) {
              recentRejectionsList.add(empApp);
            }
            break;
        }
      }
      
      // Calculate profile completion
      final profileCompletion = _calculateProfileCompletionFromUserData(userData);
      
      // Update dashboard model
      _dashboard = EmployeeDashboardModel(
        totalApplications: totalApplications,
        applicationsUnderReview: applicationsUnderReview,
        acceptedOffers: acceptedOffers,
        rejectedApplications: rejectedApplications,
        recentApplications: recentApplicationsList,
        recentRejections: recentRejectionsList,
        profileCompletionPercentage: (profileCompletion * 100).round(),
        profileSuggestions: _generateProfileSuggestions(userData),
      );

      _lastUpdated = DateTime.now();
      debugPrint('[EmployeeDashboardProvider] Dashboard loaded successfully: ${recentApplicationsList.length} recent apps');
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

  /// Convert JobApplicationModel to EmployeeApplicationModel for Dashboard list
  EmployeeApplicationModel _convertToEmployeeApp(JobApplicationModel jobApp) {
    return EmployeeApplicationModel(
      id: jobApp.id,
      employeeId: jobApp.employeeId,
      jobId: jobApp.jobId,
      jobTitle: jobApp.jobTitle,
      companyName: jobApp.companyName,
      postedBy: 'Employer', // Fallback if name not in JobApp
      status: jobApp.status.toApplicationStatus(),
      appliedAt: jobApp.appliedAt,
      coverLetter: jobApp.coverLetter,
    );
  }

  /// Generate profile improvement suggestions based on completeness
  List<String> _generateProfileSuggestions(Map<String, dynamic> userData) {
    List<String> suggestions = [];
    
    if (userData['bio'] == null || userData['bio'].toString().isEmpty) {
      suggestions.add('Add a professional bio to highlight your personality');
    }
    if (userData['skills'] == null || (userData['skills'] as List).isEmpty) {
      suggestions.add('List your top skills to stand out to employers');
    }
    if (userData['resumeUrl'] == null || userData['resumeUrl'].toString().isEmpty) {
      suggestions.add('Upload your latest resume for quicker applications');
    }
    if (userData['headline'] == null || userData['headline'].toString().isEmpty) {
      suggestions.add('Add a professional headline describing your role');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('Your profile looks great! Keep it updated for new opportunities.');
    }
    
    return suggestions;
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }
}
