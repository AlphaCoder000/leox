/// Server Actions - Main Backend Logic
/// Equivalent to web app's src/lib/actions.ts
/// Contains core business logic for job applications, interviews, etc.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/employee_application_model.dart';

class ServerActions {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

  // ======== JOB APPLICATIONS ========

  /// Apply for a job
  /// Equivalent to web app's applyForJob function
  Future<bool> applyForJob({
    required String jobId,
    required String employeeId,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      debugPrint('[ServerActions] Applying for job: $jobId');
      
      // Create application record
      final application = EmployeeApplicationModel(
        id: '', // Firestore auto-id
        employeeId: employeeId,
        jobId: jobId,

        // REQUIRED BY MODEL
        jobTitle: applicationData['jobTitle'] ?? 'Untitled Job',
        companyName: applicationData['companyName'] ?? 'Unknown Company',
        postedBy: applicationData['postedBy'] ?? 'Unknown',

        // ENUM, not string
        status: ApplicationStatus.applied,
        appliedAt: DateTime.now(),

        // OPTIONAL
        coverLetter: applicationData['coverLetter'],
      );

      // 🔁 toJson(), NOT toMap()
      await _firestore
          .collection('job_applications')
          .add(application.toJson());


      debugPrint('[ServerActions] Job application successful');
      return true;
    } catch (e) {
      debugPrint('[ServerActions] Error applying for job: $e');
      return false;
    }
  }

  /// Schedule an interview
  /// Equivalent to web app's scheduleInterview function
  Future<bool> scheduleInterview({
    required String applicationId,
    required DateTime scheduledDate,
    required String interviewType,
    required Map<String, dynamic> interviewDetails,
  }) async {
    try {
      debugPrint('[ServerActions] Scheduling interview for application: $applicationId');
      
      // Create interview record
      await _firestore
          .collection('interviews')
          .add({
            'applicationId': applicationId,
            'scheduledDate': scheduledDate.toIso8601String(),
            'type': interviewType,
            'status': 'scheduled',
            'details': interviewDetails,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update application status
      await _firestore
          .collection('job_applications')
          .doc(applicationId)
          .update({
            'status': 'interview_scheduled',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('[ServerActions] Interview scheduled successfully');
      return true;
    } catch (e) {
      debugPrint('[ServerActions] Error scheduling interview: $e');
      return false;
    }
  }

  // ======== DATABASE OPERATIONS ========

  /// Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
    required String role, // 'employee' or 'employer'
  }) async {
    try {
      debugPrint('[ServerActions] Updating $role profile: $userId');
      
      await _firestore
          .collection('${role}s')
          .doc(userId)
          .update({
            ...profileData,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('[ServerActions] Profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('[ServerActions] Error updating profile: $e');
      return false;
    }
  }

  /// Get user applications
  Future<List<Map<String, dynamic>>> getUserApplications(String userId) async {
    try {
      debugPrint('[ServerActions] Getting applications for user: $userId');
      
      final snapshot = await _firestore
          .collection('job_applications')
          .where('employeeId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('[ServerActions] Error getting user applications: $e');
      return [];
    }
  }

  /// Get job postings
  Future<List<Map<String, dynamic>>> getJobPostings({
    String? category,
    String? location,
    int? limit = 20,
  }) async {
    try {
      debugPrint('[ServerActions] Getting job postings');
      
      final snapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('[ServerActions] Error getting job postings: $e');
      return [];
    }
  }

  // ======== STATISTICS ========

  Future<Map<String, dynamic>> getUserStatistics(String userId, String role) async {
    try {
      debugPrint('[ServerActions] Getting statistics for $role: $userId');
      
      final Map<String, dynamic> stats = {};

      if (role == 'employee') {
        // Employee statistics
        final applications = await _firestore
            .collection('job_applications')
            .where('employeeId', isEqualTo: userId)
            .get();

        stats['totalApplications'] = applications.docs.length;
        stats['pendingApplications'] = applications.docs
            .where((doc) => doc['status'] == 'pending')
            .length;
        stats['interviewScheduled'] = applications.docs
            .where((doc) => doc['status'] == 'interview_scheduled')
            .length;
        stats['rejectedApplications'] = applications.docs
            .where((doc) => doc['status'] == 'rejected')
            .length;
      } else if (role == 'employer') {
        // Employer statistics
        final jobs = await _firestore
            .collection('jobs')
            .where('employerId', isEqualTo: userId)
            .get();

        stats['totalJobsPosted'] = jobs.docs.length;
        stats['activeJobs'] = jobs.docs
            .where((doc) => doc['isActive'] == true)
            .length;

        // Calculate total applications across all jobs
        int totalApplications = 0;
        for (final job in jobs.docs) {
          final applications = await _firestore
              .collection('job_applications')
              .where('jobId', isEqualTo: job.id)
              .get();
          totalApplications += applications.docs.length;
        }
        stats['totalApplications'] = totalApplications;
      }

      return stats;
    } catch (e) {
      debugPrint('[ServerActions] Error getting statistics: $e');
      return {};
    }
  }
}
