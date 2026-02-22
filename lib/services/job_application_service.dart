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
import 'dart:typed_data';
import '../models/job_application_model.dart';
import '../models/job_posting_model.dart';
import 'profile_service.dart';
import 'storage_service.dart';

class JobApplicationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();

  /// Submit a job application
  Future<String?> submitApplication({
    required String jobId,
    required String coverLetter,
    required dynamic resumeFile,
    required JobPostingModel jobPosting,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint(
        '[JobApplicationService] Submitting application for job: $jobId',
      );

      // Get employee profile
      final employeeProfile = await _profileService.getEmployeeProfile();
      if (employeeProfile == null) {
        throw Exception('Employee profile not found');
      }

      // Handle resume (optional)
      String? resumeUrl;
      String? resumeName;
      if (resumeFile != null) {
        // Determine file name and upload accordingly (supports XFile and PlatformFile)
        try {
          String fileName;
          if (resumeFile is String) {
            // Unexpected string path - treat as path
            fileName = resumeFile.split('/').last;
            final fileExtension = fileName.split('.').last;
            final uploadPath =
                'applications/${user.uid}_${jobId}_resume.$fileExtension';
            resumeUrl = await _storageService.uploadFileBytes(
              fileBytes: await File(resumeFile).readAsBytes(),
              fileName: fileName,
              folder: 'applications',
            );
            resumeName = fileName;
          } else if (resumeFile is XFile) {
            fileName = resumeFile.name ?? 'resume.pdf';
            final fileExtension = fileName.split('.').last;
            final uploadPath =
                'applications/${user.uid}_${jobId}_resume.$fileExtension';
            resumeUrl = await _storageService.uploadFile(
              resumeFile,
              uploadPath,
            );
            resumeName = fileName;
          } else if (resumeFile is PlatformFile) {
            fileName = resumeFile.name ?? 'resume.pdf';
            final fileExtension = fileName.split('.').last;
            final uploadPath =
                'applications/${user.uid}_${jobId}_resume.$fileExtension';
            // Use dedicated upload for PlatformFile
            resumeUrl = await _storageService.uploadPlatformFile(
              resumeFile,
              uploadPath,
            );
            resumeName = fileName;
          } else if (resumeFile is Uint8List) {
            // Raw bytes
            fileName = '${user.uid}_${jobId}_resume.pdf';
            resumeUrl = await _storageService.uploadFileBytes(
              fileBytes: resumeFile,
              fileName: fileName,
              folder: 'applications',
            );
            resumeName = fileName;
          } else {
            // Fallback: try bytes property
            try {
              final bytes = (resumeFile as dynamic).bytes as Uint8List?;
              if (bytes != null) {
                final fileNameFallback =
                    (resumeFile as dynamic).name ??
                    '${user.uid}_${jobId}_resume.pdf';
                resumeUrl = await _storageService.uploadFileBytes(
                  fileBytes: bytes,
                  fileName: fileNameFallback,
                  folder: 'applications',
                );
                resumeName = fileNameFallback;
              }
            } catch (_) {}
          }
        } catch (e) {
          debugPrint('[JobApplicationService] Resume upload failed: $e');
          // Don't stop the application process for resume upload failures; continue without resume
        }
      } else if (employeeProfile.resumeUrl.isNotEmpty) {
        // Use existing resume from profile
        resumeUrl = employeeProfile.resumeUrl;
        resumeName = 'resume.pdf'; // Default name since no fileName field
      }
      // Resume is optional - can be null

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
      );

      // Save to main 'applications' collection
      final docRef = await _firestore
          .collection('applications')
          .add(application.toFirestore());

      // Also store under employer and employee subcollections for easy access
      final applicationData = application.toFirestore();

      // Write under employer's applications subcollection
      if (application.employerId.isNotEmpty) {
        await _firestore
            .collection('employers')
            .doc(application.employerId)
            .collection('applications')
            .doc(docRef.id)
            .set(applicationData);
      }

      // Write under employee's applications subcollection (private to employee)
      if (application.employeeId.isNotEmpty) {
        await _firestore
            .collection('employees')
            .doc(application.employeeId)
            .collection('applications')
            .doc(docRef.id)
            .set(applicationData);
      }

      debugPrint(
        '[JobApplicationService] Application submitted successfully: ${docRef.id}',
      );
      return docRef.id;
    } catch (e) {
      debugPrint('[JobApplicationService] Error submitting application: $e');
      rethrow;
    }
  }

  /// Get all applications for an employer
  Future<List<JobApplicationModel>> getEmployerApplications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint(
        '[JobApplicationService] Getting applications for employer: ${user.uid}',
      );

      final snapshot =
          await _firestore
              .collection('applications')
              .where('employerId', isEqualTo: user.uid)
              .orderBy('appliedAt', descending: true)
              .get();

      final applications =
          snapshot.docs
              .map((doc) => JobApplicationModel.fromFirestore(doc))
              .toList();

      debugPrint(
        '[JobApplicationService] Found ${applications.length} applications',
      );
      return applications;
    } catch (e) {
      debugPrint(
        '[JobApplicationService] Error getting employer applications: $e',
      );
      rethrow;
    }
  }

  /// Get applications for a specific job posting
  Future<List<JobApplicationModel>> getJobApplications(String jobId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint(
        '[JobApplicationService] Getting applications for job: $jobId',
      );

      final snapshot =
          await _firestore
              .collection('applications')
              .where('jobId', isEqualTo: jobId)
              .where('employerId', isEqualTo: user.uid)
              .orderBy('appliedAt', descending: true)
              .get();

      final applications =
          snapshot.docs
              .map((doc) => JobApplicationModel.fromFirestore(doc))
              .toList();

      debugPrint(
        '[JobApplicationService] Found ${applications.length} applications for job $jobId',
      );
      return applications;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting job applications: $e');
      rethrow;
    }
  }

  /// Get all applications submitted by current employee
  Future<List<JobApplicationModel>> getEmployeeApplications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint(
        '[JobApplicationService] Getting applications for employee: ${user.uid}',
      );

      final snapshot =
          await _firestore
              .collection('applications')
              .where('employeeId', isEqualTo: user.uid)
              .orderBy('appliedAt', descending: true)
              .get();

      final applications =
          snapshot.docs
              .map((doc) => JobApplicationModel.fromFirestore(doc))
              .toList();

      debugPrint(
        '[JobApplicationService] Found ${applications.length} applications',
      );
      return applications;
    } catch (e) {
      debugPrint(
        '[JobApplicationService] Error getting employee applications: $e',
      );
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
      if (user == null) throw Exception('User not authenticated');

      debugPrint(
        '[JobApplicationService] Updating application $applicationId to status: $status',
      );

      final updateData = {
        'status': status,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': user.uid,
      };

      if (notes != null) {
        updateData['reviewNotes'] = notes;
      }

      await _firestore
          .collection('applications')
          .doc(applicationId)
          .update(updateData);

      debugPrint(
        '[JobApplicationService] Application status updated successfully',
      );
      return true;
    } catch (e) {
      debugPrint(
        '[JobApplicationService] Error updating application status: $e',
      );
      return false;
    }
  }

  /// Get application by ID
  Future<JobApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      debugPrint('[JobApplicationService] Getting application: $applicationId');

      final doc =
          await _firestore.collection('applications').doc(applicationId).get();

      if (!doc.exists) return null;

      final application = JobApplicationModel.fromFirestore(doc);

      // Verify user has access to this application
      if (application.employerId != user.uid &&
          application.employeeId != user.uid) {
        throw Exception('Access denied');
      }

      debugPrint('[JobApplicationService] Application retrieved successfully');
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

      debugPrint(
        '[JobApplicationService] Deleting application: $applicationId',
      );

      // Get application to verify ownership
      final application = await getApplicationById(applicationId);
      if (application == null) throw Exception('Application not found');

      if (application.employeeId != user.uid) {
        throw Exception(
          'Access denied - you can only delete your own applications',
        );
      }

      // Delete from Firestore
      await _firestore.collection('applications').doc(applicationId).delete();

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

      debugPrint(
        '[JobApplicationService] Getting application stats for employer: ${user.uid}',
      );

      final snapshot =
          await _firestore
              .collection('applications')
              .where('employerId', isEqualTo: user.uid)
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
        stats[status] = (stats[status] ?? 0) + 1;
      }

      debugPrint('[JobApplicationService] Application stats: $stats');
      return stats;
    } catch (e) {
      debugPrint('[JobApplicationService] Error getting application stats: $e');
      return {};
    }
  }
}
