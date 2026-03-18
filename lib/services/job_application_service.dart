/// Job Application Service
///
/// Handles all job application operations including:
/// - Submitting job applications
/// - Managing application status
/// - Retrieving applications for employers
/// - Managing candidate information
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/job_application_model.dart';
import '../models/job_posting_model.dart';
import '../models/candidate_model.dart';
import '../models/employee_profile_model.dart';
import 'profile_service.dart';
import 'storage_service.dart';

import '../services/notification_service.dart';

class JobApplicationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();

  /// Submit a job application
  Future<String> submitApplication({
    required String jobId,
    required String coverLetter,
    dynamic resumeFile,
    required JobPostingModel jobPosting,
    String experience = '',
    String expectedSalary = '',
    String availability = '',
    String linkedIn = '',
    String portfolio = '',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (jobId.isEmpty) {
        debugPrint('[JobApplicationService] WARNING: jobId is empty! Using jobPosting.id if available.');
        jobId = jobPosting.id;
      }

      debugPrint('[JobApplicationService] Submitting application:');
      debugPrint('  - Job ID: "$jobId"');
      debugPrint('  - Job Title: "${jobPosting.title}"');
      debugPrint('  - Employee ID: "${user.uid}"');
      debugPrint('  - Employer ID: "${jobPosting.employerId}"');

      // Get employee profile
      var employeeProfile = await _profileService.getEmployeeProfile();
      
      // If profile is missing, create a minimal one to allow application
      if (employeeProfile == null) {
        debugPrint('[JobApplicationService] Profile not found, creating minimal profile for ${user.uid}');
        
        final nameParts = (user.displayName ?? 'Candidate').split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final newProfile = EmployeeProfileModel(
          id: user.uid,
          email: user.email ?? '',
          firstName: firstName,
          lastName: lastName,
          skills: [],
        );
        
        try {
          await _profileService.saveEmployeeProfile(newProfile);
          employeeProfile = newProfile;
          debugPrint('[JobApplicationService] Minimal profile created successfully');
        } catch (e) {
          debugPrint('[JobApplicationService] Failed to create recovery profile: $e');
          throw Exception('Employee profile not found and could not be created automatically. Please set up your profile first.');
        }
      }

      // Handle resume (optional)
      String? resumeUrl;
      String? resumeName;
      
      if (resumeFile != null) {
        try {
          if (resumeFile is PlatformFile) {
            final fileName = resumeFile.name;
            final fileExtension = fileName.split('.').last;
            final uploadPath = 'applications/${user.uid}_${jobId}_resume.$fileExtension';
            
            resumeUrl = await _storageService.uploadPlatformFile(resumeFile, uploadPath);
            resumeName = fileName;
          } else if (resumeFile is XFile) {
            final fileName = resumeFile.name;
            final fileExtension = fileName.split('.').last;
            final uploadPath = 'applications/${user.uid}_${jobId}_resume.$fileExtension';
            
            resumeUrl = await _storageService.uploadFile(resumeFile, uploadPath);
            resumeName = fileName;
          } else if (resumeFile is String) {
            // Assume it's a file path
            final file = File(resumeFile);
            if (await file.exists()) {
              final fileName = resumeFile.split(Platform.pathSeparator).last;
              resumeUrl = await _storageService.uploadFileBytes(
                fileBytes: await file.readAsBytes(),
                fileName: fileName,
                folder: 'applications',
              );
              resumeName = fileName;
            }
          }
        } catch (e) {
          debugPrint('[JobApplicationService] Resume upload failed: $e');
        }
      }

      // If no new resume uploaded, use one from profile if it exists
      if (resumeUrl == null && employeeProfile.resumeUrl.isNotEmpty) {
        resumeUrl = employeeProfile.resumeUrl;
        resumeName = employeeProfile.resumeName.isNotEmpty ? employeeProfile.resumeName : 'resume.pdf';
      }
      
      // Create application document
      final application = JobApplicationModel(
        id: '', // Will be set by Firestore
        jobId: jobId,
        employeeId: user.uid,
        employerId: jobPosting.employerId,
        status: 'pending',
        coverLetter: coverLetter,
        resumeUrl: resumeUrl, // Can be null
        resumeName: resumeName, // Can be null
        appliedAt: DateTime.now(),
        employeeName:
            '${employeeProfile.firstName} ${employeeProfile.lastName}',
        employeeEmail: employeeProfile.email,
        employeePhone: employeeProfile.phone ?? '',
        employeeProfilePicture: employeeProfile.profilePicture,
        employeeSkills: employeeProfile.skills,
        employeeHeadline: employeeProfile.headline,
        jobTitle: jobPosting.title,
        jobDepartment: jobPosting.department,
        companyName: jobPosting.companyName,
        jobType: jobPosting.jobType,
        jobLocation: jobPosting.location,
        salary: jobPosting.salary,
        experience: experience,
        expectedSalary: expectedSalary,
        availability: availability,
        linkedIn: linkedIn,
        portfolio: portfolio,
      );

      // Save to main 'applications' collection
      debugPrint('[JobApplicationService] Attempting to write to "applications" collection...');
      final docRef = await _firestore
          .collection('applications')
          .add(application.toFirestore());
      // Send notification to employer
    try {
      await _notificationService.sendNotification(
        recipientId: jobPosting.employerId,
        title: 'New Application Received',
        message: '${employeeProfile.firstName} ${employeeProfile.lastName} applied for your ${jobPosting.title} position.',
        type: 'new_application',
        data: {
          'applicationId': docRef.id,
          'jobId': jobId,
          'applicantId': user.uid,
        },
      );
    } catch (e) {
      debugPrint('[JobApplicationService] Error sending employer notification: $e');
    }

    // Send confirmation notification to employee
    try {
      await _notificationService.sendNotification(
        recipientId: user.uid,
        title: 'Application Submitted',
        message: 'You have successfully applied for the ${jobPosting.title} position at ${jobPosting.companyName}.',
        type: 'application_submitted',
        data: {
          'applicationId': docRef.id,
          'jobId': jobId,
        },
      );
    } catch (e) {
      debugPrint('[JobApplicationService] Error sending employee notification: $e');
    }

    debugPrint('[JobApplicationService] Successfully created application document with ID: ${docRef.id}');

      // Also store in 'candidates' collection as requested
      final candidate = CandidateModel(
        id: docRef.id,
        appliedAt: application.appliedAt,
        avatarUrl: application.employeeProfilePicture,
        email: application.employeeEmail,
        jobAppliedFor: application.jobId,
        employeeId: application.employeeId,
        employerId: application.employerId,
        name: application.employeeName,
        phone: application.employeePhone,
        resumeUrl: application.resumeUrl ?? '',
        skills: application.employeeSkills,
        status: application.status,
        coverLetter: application.coverLetter,
        jobTitle: application.jobTitle,
        jobDepartment: application.jobDepartment,
        jobType: application.jobType,
        jobLocation: application.jobLocation,
        headline: application.employeeHeadline,
        experience: application.experience,
        expectedSalary: application.expectedSalary,
        availability: application.availability,
        linkedIn: application.linkedIn,
        portfolio: application.portfolio,
      );

      debugPrint('[JobApplicationService] Attempting to write to "candidates" collection...');
      await _firestore
          .collection('candidates')
          .doc(docRef.id)
          .set(candidate.toFirestore());
      debugPrint('[JobApplicationService] Successfully created candidate document');

      // Also store under employer and employee subcollections for easy access
      final applicationData = application.toFirestore();

      // ======== NEW REQUESTED STRUCTURES ========

      // 1. applications -> employerId -> applied_jobs -> jobId -> all_applications -> applicationId
      if (application.employerId.isNotEmpty && application.jobId.isNotEmpty) {
        debugPrint('[JobApplicationService] Writing to nested applications structure');
        await _firestore
            .collection('applications')
            .doc(application.employerId)
            .collection('applied_jobs')
            .doc(application.jobId)
            .collection('all_applications')
            .doc(docRef.id)
            .set(applicationData);
      }

      // 2. candidates -> employerId -> roles -> roleName -> all_candidates -> applicationId
      if (application.employerId.isNotEmpty && application.jobTitle.isNotEmpty) {
        debugPrint('[JobApplicationService] Writing to nested candidates structure');
        // Clean role name for document ID
        final roleName = application.jobTitle.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
        await _firestore
            .collection('candidates')
            .doc(application.employerId)
            .collection('roles')
            .doc(roleName)
            .collection('all_candidates')
            .doc(docRef.id)
            .set(candidate.toFirestore());
      }

      // ======== PRESERVE PREVIOUS STRUCTURES FOR BACKWARD COMPATIBILITY ========

      // Write under employer's applications subcollection
      if (application.employerId.isNotEmpty) {
        debugPrint('[JobApplicationService] Writing to employer applications subcollection: ${application.employerId}');
        await _firestore
            .collection('employers')
            .doc(application.employerId)
            .collection('applications')
            .doc(docRef.id)
            .set(applicationData);
      }

      // Write under employee's applications subcollection (private to employee)
      if (application.employeeId.isNotEmpty) {
        debugPrint('[JobApplicationService] Writing to employee applications subcollection: ${application.employeeId}');
        await _firestore
            .collection('employees')
            .doc(application.employeeId)
            .collection('applications')
            .doc(docRef.id)
            .set(applicationData);
      }

      debugPrint(
        '[JobApplicationService] Application lifecycle complete for ID: ${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      debugPrint('[JobApplicationService] CRITICAL Error in submitApplication: $e');
      rethrow;
    }
  }

  /// Get all applications for an employer (Fetching from subcollection for web-app compatibility)
  Future<List<JobApplicationModel>> getEmployerApplications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Fetching applications for employer: ${user.uid} (from subcollection)');

      // Fetch from employer's own applications subcollection (Web App style)
      final snapshot = await _firestore
          .collection('employers')
          .doc(user.uid)
          .collection('applications')
          .get();

      final applications = snapshot.docs
          .map((doc) => JobApplicationModel.fromFirestore(doc))
          .toList();

      // Sort in-memory
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      debugPrint('[JobApplicationService] Found ${applications.length} applications in subcollection');
      
      // Fallback: If nothing in subcollection, check global applications (for legacy/cross-app sync)
      if (applications.isEmpty) {
         final globalSnapshot = await _firestore
            .collection('applications')
            .where('employerId', isEqualTo: user.uid)
            .get();
         
         final globalApps = globalSnapshot.docs
            .map((doc) => JobApplicationModel.fromFirestore(doc))
            .toList();
         
         globalApps.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
         return globalApps;
      }

      return applications;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting employer applications: $e');
      rethrow;
    }
  }

  /// Get all candidates for an employer (Fetching from applications for web-app compatibility)
  Future<List<CandidateModel>> getEmployerCandidates() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      debugPrint('[JobApplicationService] Fetching candidates for employer UID: ${user.uid}');
      
      // In many web apps, candidates are just the applications view
      final apps = await getEmployerApplications();
      
      if (apps.isNotEmpty) {
        return apps.map((app) => CandidateModel.fromJobApplication(app)).toList();
      }

      // secondary fallback: Check top-level candidates collection
      final snapshot = await _firestore
          .collection('candidates')
          .where('employerId', isEqualTo: user.uid)
          .get();

      final list = snapshot.docs.map((doc) => CandidateModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return list;
    } catch (e) {
      debugPrint('[JobApplicationService] Error in getEmployerCandidates: $e');
      return [];
    }
  }

  /// Get candidates for a specific role from the nested structure
  Future<List<CandidateModel>> getEmployerCandidatesByRole(String jobTitle) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final roleName = jobTitle.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      debugPrint('[JobApplicationService] Fetching candidates for role: $roleName');

      final snapshot = await _firestore
          .collection('candidates')
          .doc(user.uid)
          .collection('roles')
          .doc(roleName)
          .collection('all_candidates')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) => CandidateModel.fromFirestore(doc)).toList();
        list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return list;
      }

      // fallback to job title match in global candidates
      final globalSnapshot = await _firestore
          .collection('candidates')
          .where('employerId', isEqualTo: user.uid)
          .where('jobTitle', isEqualTo: jobTitle)
          .get();

      final globalList = globalSnapshot.docs.map((doc) => CandidateModel.fromFirestore(doc)).toList();
      globalList.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return globalList;
    } catch (e) {
      debugPrint('[JobApplicationService] Error in getEmployerCandidatesByRole: $e');
      return [];
    }
  }

  /// Get applications for a specific job posting
  Future<List<JobApplicationModel>> getJobApplications(String jobId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Getting applications for job: $jobId');

      // Check global collection first as it's easier to filter by jobId
      final snapshot = await _firestore
              .collection('applications')
              .where('jobId', isEqualTo: jobId)
              .where('employerId', isEqualTo: user.uid)
              .get();

      final list = snapshot.docs.map((doc) => JobApplicationModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return list;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting job applications: $e');
      rethrow;
    }
  }

  /// Get all applications submitted by current employee (From subcollection)
  Future<List<JobApplicationModel>> getEmployeeApplications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Getting applications for employee: ${user.uid} (from subcollection)');

      // Fetch from employee's personal applications subcollection (Web App style)
      final snapshot = await _firestore
              .collection('employees')
              .doc(user.uid)
              .collection('applications')
              .get();

      final applications = snapshot.docs
              .map((doc) => JobApplicationModel.fromFirestore(doc))
              .toList();

      // Sort in-memory
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

      // Fallback to global query
      if (applications.isEmpty) {
        final globalSnapshot = await _firestore
            .collection('applications')
            .where('employeeId', isEqualTo: user.uid)
            .get();
        
        final globalApps = globalSnapshot.docs
            .map((doc) => JobApplicationModel.fromFirestore(doc))
            .toList();
        
        globalApps.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return globalApps;
      }

      return applications;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting employee applications: $e');
      rethrow;
    }
  }

  /// Update application status
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[JobApplicationService] ERROR: User not authenticated');
        throw Exception('User not authenticated');
      }

      debugPrint('[JobApplicationService] === START STATUS UPDATE ===');
      debugPrint('[JobApplicationService] Application: $applicationId');
      debugPrint('[JobApplicationService] New Status: $status');

      // 1. Fetch current application data
      JobApplicationModel? app = await getApplicationById(applicationId);
      
      if (app == null) {
        debugPrint('[JobApplicationService] WARNING: Application not found in global collection');
        // We still try to proceed if we can find it in Candidates
        final candidates = await getEmployerCandidates();
        final cand = candidates.firstWhere((c) => c.id == applicationId, orElse: () => throw Exception('Application not found even in candidate list'));
        
        debugPrint('[JobApplicationService] Recovery: Found candidate info for $applicationId');
        // Minimal app model for notification purposes
        app = JobApplicationModel(
          id: cand.id,
          jobId: cand.jobAppliedFor,
          employeeId: cand.employeeId,
          employerId: cand.employerId,
          status: cand.status,
          appliedAt: cand.appliedAt,
          jobTitle: cand.jobTitle,
          companyName: 'the employer', // CandidateModel doesn't have companyName
          coverLetter: cand.coverLetter,
          employeeName: cand.name,
          employeeEmail: cand.email,
        );
      }

      final currentApp = app;

      debugPrint('[JobApplicationService] Found Employee ID for notify: ${currentApp.employeeId}');
      debugPrint('[JobApplicationService] Found Employer ID: ${currentApp.employerId}');

      final updateData = {
        'status': status,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': user.uid,
      };

      if (notes != null) {
        updateData['reviewNotes'] = notes;
      }

      // 2. Update global application
      await _firestore
          .collection('applications')
          .doc(applicationId)
          .update(updateData);
      debugPrint('[JobApplicationService] Step 2: Global application updated');

      // 3. Update in 'candidates' collection
      try {
        await _firestore
            .collection('candidates')
            .doc(applicationId)
            .update({'status': status});
        debugPrint('[JobApplicationService] Step 3: Flat candidate updated');
      } catch (e) {
        debugPrint('[JobApplicationService] Step 3 Error (can be ignored if non-existent): $e');
      }

      // 4. Update in user subcollections
      try {
        if (currentApp.employerId.isNotEmpty) {
          await _firestore
              .collection('employers')
              .doc(currentApp.employerId)
              .collection('applications')
              .doc(applicationId)
              .update(updateData);
        }
        if (currentApp.employeeId.isNotEmpty) {
          await _firestore
              .collection('employees')
              .doc(currentApp.employeeId)
              .collection('applications')
              .doc(applicationId)
              .update(updateData);
        }
        debugPrint('[JobApplicationService] Step 4: Subcollections updated');
      } catch (e) {
        debugPrint('[JobApplicationService] Step 4 Error: $e');
      }

      // 5. Update nested structures
      try {
        if (currentApp.employerId.isNotEmpty && currentApp.jobId.isNotEmpty) {
          await _firestore
              .collection('applications')
              .doc(currentApp.employerId)
              .collection('applied_jobs')
              .doc(currentApp.jobId)
              .collection('all_applications')
              .doc(applicationId)
              .update({'status': status});

          final roleName = currentApp.jobTitle.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
          await _firestore
              .collection('candidates')
              .doc(currentApp.employerId)
              .collection('roles')
              .doc(roleName)
              .collection('all_candidates')
              .doc(applicationId)
              .update({'status': status});
          debugPrint('[JobApplicationService] Step 5: Nested structures updated');
        }
      } catch (e) {
        debugPrint('[JobApplicationService] Step 5 Error: $e');
      }

      // 6. Send notification to employee
      try {
        String title = '';
        String message = '';
        
        switch (status) {
          case 'reviewed':
            title = 'Application Under Review';
            message = 'Your application for ${currentApp.jobTitle} is now being reviewed by ${currentApp.companyName.isEmpty ? "the employer" : currentApp.companyName}.';
            break;
          case 'shortlisted':
            title = 'Congratulations! You are Shortlisted';
            message = 'You have been shortlisted for the ${currentApp.jobTitle} position. Expect to hear more soon!';
            break;
          case 'hired':
            title = '🎉 You are HIRED!';
            message = 'Great news! You have been selected for the ${currentApp.jobTitle} role. Welcome aboard!';
            break;
          case 'rejected':
            title = 'Application Update';
            message = 'Thank you for your interest in the ${currentApp.jobTitle} position. Unfortunately, the company has decided to move forward with other candidates.';
            break;
          default:
            title = 'Application Status Updated';
            message = 'The status of your application for ${currentApp.jobTitle} has been updated to $status.';
        }

        if (title.isNotEmpty && currentApp.employeeId.isNotEmpty) {
          debugPrint('[JobApplicationService] Sending notification to employee: ${currentApp.employeeId}');
          await _notificationService.sendNotification(
            recipientId: currentApp.employeeId,
            title: title,
            message: message,
            type: ['hired', 'rejected', 'shortlisted'].contains(status) ? status : 'application_status',
            data: {
              'applicationId': applicationId,
              'jobId': currentApp.jobId,
              'status': status,
            },
          );
          debugPrint('[JobApplicationService] Step 6: Notification sent');
        } else {
          debugPrint('[JobApplicationService] Step 6 SKIPPED: Missing title or employeeId');
        }
      } catch (e) {
        debugPrint('[JobApplicationService] Step 6 Error (Notification): $e');
      }

      debugPrint('[JobApplicationService] === END STATUS UPDATE (SUCCESS) ===');
      return true;
    } catch (e) {
      debugPrint('[JobApplicationService] === STATUS UPDATE FAILED ===');
      debugPrint('[JobApplicationService] Error: $e');
      return false;
    }
  }

  /// Get application by ID
  Future<JobApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Getting application: $applicationId');

      final doc = await _firestore.collection('applications').doc(applicationId).get();

      if (!doc.exists) return null;

      final application = JobApplicationModel.fromFirestore(doc);

      // Verify user has access to this application
      // Support both UID and Email for legacy compatibility
      final isEmployer = application.employerId == user.uid || application.employerId == user.email;
      final isEmployee = application.employeeId == user.uid || application.employeeId == user.email;

      if (!isEmployer && !isEmployee) {
        debugPrint('[JobApplicationService] Access Denied: User ${user.uid} (${user.email}) does not match employer ${application.employerId} or employee ${application.employeeId}');
        throw Exception('Access denied');
      }

      return application;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting application: $e');
      rethrow;
    }
  }

  /// Delete application (employee only)
  Future<bool> deleteApplication(String applicationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Deleting application: $applicationId');

      // Get application to verify ownership
      final application = await getApplicationById(applicationId);
      if (application == null) throw Exception('Application not found');

      if (application.employeeId != user.uid) {
        throw Exception('Access denied - you can only delete your own applications');
      }

      // Delete from main collections
      await _firestore.collection('applications').doc(applicationId).delete();
      await _firestore.collection('candidates').doc(applicationId).delete();

      // Delete from employer/employee subcollections
      await _firestore
          .collection('employers')
          .doc(application.employerId)
          .collection('applications')
          .doc(applicationId)
          .delete();

      await _firestore
          .collection('employees')
          .doc(application.employeeId)
          .collection('applications')
          .doc(applicationId)
          .delete();

      // Delete from nested structures
      try {
        await _firestore
            .collection('applications')
            .doc(application.employerId)
            .collection('applied_jobs')
            .doc(application.jobId)
            .collection('all_applications')
            .doc(applicationId)
            .delete();

        final roleName = application.jobTitle.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
        await _firestore
            .collection('candidates')
            .doc(application.employerId)
            .collection('roles')
            .doc(roleName)
            .collection('all_candidates')
            .doc(applicationId)
            .delete();
      } catch (e) {
        debugPrint('[JobApplicationService] Error deleting from nested structures: $e');
      }

      debugPrint('[JobApplicationService] Application deleted successfully');
      return true;
    } catch (e) {
      debugPrint('[JobApplicationService] Error deleting application: $e');
      return false;
    }
  }

  /// Get application statistics for employer
  Future<Map<String, int>> getEmployerApplicationStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Getting application stats for employer from subcollection');

      final snapshot = await _firestore
              .collection('employers')
              .doc(user.uid)
              .collection('applications')
              .get();

      final stats = <String, int>{
        'total': snapshot.docs.length,
        'pending': 0,
        'reviewed': 0,
        'shortlisted': 0,
        'rejected': 0,
        'hired': 0,
      };

      for (final doc in snapshot.docs) {
        final status = doc['status'] as String? ?? 'pending';
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }
      }

      return stats;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting application stats: $e');
      return {};
    }
  }
}
