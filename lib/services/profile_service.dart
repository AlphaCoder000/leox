/// Profile Service - Specialized Business Logic
/// Equivalent to web app's src/lib/services/profileService.ts
/// Contains specialized business logic for user profiles

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_profile_model.dart';
import '../models/employer_profile_model.dart';
import '../backend/ai_workflows.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIWorkflows _aiWorkflows = AIWorkflows();

  // ======== EMPLOYEE PROFILE SERVICES ========

  /// Get complete employee profile with AI insights
  Future<Map<String, dynamic>> getEmployeeProfile(String employeeId) async {
    try {
      debugPrint('[ProfileService] Getting employee profile: $employeeId');
      
      // Get basic profile data
      final profileDoc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();

      if (!profileDoc.exists) {
        throw Exception('Employee profile not found');
      }

      final profileData = profileDoc.data()!;
      
      // Get AI insights if available
      Map<String, dynamic> aiInsights = {};
      if (profileData['resumeText'] != null) {
        aiInsights = await _getAIInsights(profileData);
      }

      // Get application statistics
      final applications = await _firestore
          .collection('job_applications')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      final stats = {
        'totalApplications': applications.docs.length,
        'pendingApplications': applications.docs
            .where((doc) => doc['status'] == 'pending')
            .length,
        'interviewScheduled': applications.docs
            .where((doc) => doc['status'] == 'interview_scheduled')
            .length,
        'rejectedApplications': applications.docs
            .where((doc) => doc['status'] == 'rejected')
            .length,
        'acceptedApplications': applications.docs
            .where((doc) => doc['status'] == 'accepted')
            .length,
      };

      return {
        'profile': profileData,
        'aiInsights': aiInsights,
        'statistics': stats,
        'profileStrength': aiInsights['profileStrength'] ?? 0.0,
      };
    } catch (e) {
      debugPrint('[ProfileService] Error getting employee profile: $e');
      throw e;
    }
  }

  /// Update employee profile with AI optimization
  Future<bool> updateEmployeeProfile({
    required String employeeId,
    required Map<String, dynamic> profileData,
    bool optimizeWithAI = false,
  }) async {
    try {
      debugPrint('[ProfileService] Updating employee profile: $employeeId');
      
      Map<String, dynamic> updateData = Map.from(profileData);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // AI optimization if requested
      if (optimizeWithAI && profileData['targetRole'] != null) {
        final optimization = await _aiWorkflows.optimizeProfile(
          profileData: profileData,
          targetRole: profileData['targetRole'],
        );

        if (optimization['success'] == true) {
          updateData['aiOptimizedProfile'] = optimization['optimizedProfile'];
          updateData['profileSuggestions'] = optimization['suggestions'];
          updateData['profileStrength'] = optimization['profileStrength'];
          updateData['improvementAreas'] = optimization['improvementAreas'];
        }
      }

      await _firestore
          .collection('employees')
          .doc(employeeId)
          .update(updateData);

      debugPrint('[ProfileService] Employee profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('[ProfileService] Error updating employee profile: $e');
      return false;
    }
  }

  /// Parse and update resume
  Future<Map<String, dynamic>> parseAndUpdateResume({
    required String employeeId,
    String? resumeFileUrl,
    String? resumeText,
  }) async {
    try {
      debugPrint('[ProfileService] Parsing and updating resume');
      
      // Parse resume using AI
      final parseResult = await _aiWorkflows.parseResume(
        resumeFileUrl: resumeFileUrl,
        resumeText: resumeText,
      );

      if (parseResult['success'] == true) {
        // Update profile with parsed data
        await _firestore
            .collection('employees')
            .doc(employeeId)
            .update({
              'resumeData': parseResult,
              'resumeFileUrl': resumeFileUrl,
              'resumeText': resumeText,
              'lastResumeUpdate': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

        debugPrint('[ProfileService] Resume parsed and updated successfully');
        return parseResult;
      } else {
        throw Exception(parseResult['error'] ?? 'Resume parsing failed');
      }
    } catch (e) {
      debugPrint('[ProfileService] Error parsing resume: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ======== EMPLOYER PROFILE SERVICES ========

  /// Get complete employer profile
  Future<Map<String, dynamic>> getEmployerProfile(String employerId) async {
    try {
      debugPrint('[ProfileService] Getting employer profile: $employerId');
      
      // Get basic profile data
      final profileDoc = await _firestore
          .collection('employers')
          .doc(employerId)
          .get();

      if (!profileDoc.exists) {
        throw Exception('Employer profile not found');
      }

      final profileData = profileDoc.data()!;
      
      // Get job statistics
      final jobs = await _firestore
          .collection('jobs')
          .where('employerId', isEqualTo: employerId)
          .get();

      // Get application statistics
      int totalApplications = 0;
      for (final job in jobs.docs) {
        final applications = await _firestore
            .collection('job_applications')
            .where('jobId', isEqualTo: job.id)
            .get();
        totalApplications += applications.docs.length;
      }

      final stats = {
        'totalJobsPosted': jobs.docs.length,
        'activeJobs': jobs.docs
            .where((doc) => doc['isActive'] == true)
            .length,
        'totalApplications': totalApplications,
        'hiredCount': profileData['hiredCount'] ?? 0,
        'companySize': profileData['companySize'] ?? '',
        'industry': profileData['industry'] ?? '',
      };

      return {
        'profile': profileData,
        'statistics': stats,
      };
    } catch (e) {
      debugPrint('[ProfileService] Error getting employer profile: $e');
      throw e;
    }
  }

  /// Update employer profile
  Future<bool> updateEmployerProfile({
    required String employerId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      debugPrint('[ProfileService] Updating employer profile: $employerId');
      
      final updateData = Map.from(profileData);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('employers')
          .doc(employerId)
          .update(updateData);

      debugPrint('[ProfileService] Employer profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('[ProfileService] Error updating employer profile: $e');
      return false;
    }
  }

  // ======== PROFILE COMPLETENESS ========

  /// Calculate profile completeness score
  Future<Map<String, dynamic>> calculateProfileCompleteness({
    required String userId,
    required String role, // 'employee' or 'employer'
  }) async {
    try {
      debugPrint('[ProfileService] Calculating profile completeness for $role');
      
      final profileDoc = await _firestore
          .collection('${role}s')
          .doc(userId)
          .get();

      if (!profileDoc.exists) {
        return {'completeness': 0.0, 'missingFields': []};
      }

      final profileData = profileDoc.data()!;
      final List<String> missingFields = [];
      double completeness = 0.0;
      int totalFields = 0;
      int completedFields = 0;

      if (role == 'employee') {
        // Employee required fields
        final requiredFields = [
          'firstName', 'lastName', 'email', 'phone',
          'location', 'bio', 'experience', 'education',
          'skills', 'resumeFileUrl'
        ];

        for (final field in requiredFields) {
          totalFields++;
          if (profileData[field] != null && 
              profileData[field].toString().isNotEmpty) {
            completedFields++;
          } else {
            missingFields.add(field);
          }
        }
      } else if (role == 'employer') {
        // Employer required fields
        final requiredFields = [
          'companyName', 'companyEmail', 'companyPhone',
          'companyDescription', 'industry', 'companySize',
          'location', 'website', 'logoUrl'
        ];

        for (final field in requiredFields) {
          totalFields++;
          if (profileData[field] != null && 
              profileData[field].toString().isNotEmpty) {
            completedFields++;
          } else {
            missingFields.add(field);
          }
        }
      }

      completeness = totalFields > 0 ? (completedFields / totalFields) * 100 : 0.0;

      return {
        'completeness': completeness,
        'completedFields': completedFields,
        'totalFields': totalFields,
        'missingFields': missingFields,
        'isComplete': completeness >= 90.0,
      };
    } catch (e) {
      debugPrint('[ProfileService] Error calculating profile completeness: $e');
      return {
        'completeness': 0.0,
        'missingFields': [],
      };
    }
  }

  // ======== PROFILE VERIFICATION ========

  /// Verify profile information
  Future<bool> verifyProfile({
    required String userId,
    required String role,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      debugPrint('[ProfileService] Verifying $role profile');
      
      await _firestore
          .collection('${role}s')
          .doc(userId)
          .update({
            'verification': {
              'isVerified': true,
              'verifiedAt': FieldValue.serverTimestamp(),
              'verificationData': verificationData,
              'status': 'verified',
            },
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('[ProfileService] Profile verified successfully');
      return true;
    } catch (e) {
      debugPrint('[ProfileService] Error verifying profile: $e');
      return false;
    }
  }

  // ======== HELPER METHODS ========

  Future<Map<String, dynamic>> _getAIInsights(Map<String, dynamic> profileData) async {
    try {
      // Get AI insights for the profile
      final insights = {
        'profileStrength': 0.0,
        'suggestions': <String>[],
        'improvementAreas': <String>[],
      };

      // Add AI-based insights here when available
      if (profileData['resumeData'] != null) {
        insights['profileStrength'] = profileData['resumeData']['confidence'] ?? 0.0;
      }

      return insights;
    } catch (e) {
      debugPrint('[ProfileService] Error getting AI insights: $e');
      return {};
    }
  }

  /// Get profile recommendations
  Future<Map<String, dynamic>> getProfileRecommendations({
    required String userId,
    required String role,
  }) async {
    try {
      debugPrint('[ProfileService] Getting profile recommendations');
      
      final profileDoc = await _firestore
          .collection('${role}s')
          .doc(userId)
          .get();

      if (!profileDoc.exists) {
        return {'recommendations': <String>[]};
      }

      final profileData = profileDoc.data()!;
      final List<String> recommendations = [];

      if (role == 'employee') {
        // Employee-specific recommendations
        if (profileData['resumeFileUrl'] == null) {
          recommendations.add('Upload your resume to increase profile visibility');
        }
        if (profileData['skills'] == null || (profileData['skills'] as List).isEmpty) {
          recommendations.add('Add your skills to attract employers');
        }
        if (profileData['experience'] == null || (profileData['experience'] as List).isEmpty) {
          recommendations.add('Add your work experience to complete your profile');
        }
      } else if (role == 'employer') {
        // Employer-specific recommendations
        if (profileData['companyDescription'] == null || 
            profileData['companyDescription'].toString().isEmpty) {
          recommendations.add('Add company description to attract candidates');
        }
        if (profileData['logoUrl'] == null) {
          recommendations.add('Add company logo to build brand recognition');
        }
        if (profileData['website'] == null) {
          recommendations.add('Add company website for more information');
        }
      }

      return {
        'recommendations': recommendations,
        'hasRecommendations': recommendations.isNotEmpty,
      };
    } catch (e) {
      debugPrint('[ProfileService] Error getting profile recommendations: $e');
      return {'recommendations': <String>[]};
    }
  }
}
