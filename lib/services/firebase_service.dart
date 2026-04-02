import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/employee_application_model.dart';

/// Firebase Service - Centralized Database Operations
/// 
/// Handles all Firestore operations for jobs, applications, and profiles.
/// Provides a clean interface between UI and Firebase backend.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ======== JOB OPERATIONS ========

  /// Post a new job to Firestore
  Future<void> postJob(JobModel job) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Match the Firebase Jobs collection structure from your image
      final jobData = {
        'title': job.title,
        'department': job.department,
        'category': job.category,
        'description': job.description,
        'requirements': job.requirements,
        'postedOn': Timestamp.fromDate(job.postedOn),
        'employerId': user.uid,
        'companyName': job.companyName,
        'location': job.location,
        'jobType': job.jobType,
        'experienceLevel': job.experienceLevel,
        'salaryRange': job.salaryRange,
        'skills': job.skills,
        'benefits': job.benefits,
        'status': 'Open',
        'postedBy': user.uid,
        'applicationCount': 0,
        'deadline': job.deadline != null ? Timestamp.fromDate(job.deadline!) : null,
        'additionalInfo': job.additionalInfo,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('jobs').add(jobData);
      debugPrint('[FirebaseService] Job posted successfully: ${job.title}');
    } catch (e) {
      debugPrint('[FirebaseService] Error posting job: $e');
      rethrow;
    }
  }

  /// Get all jobs posted by current employer
  Future<List<JobModel>> getEmployerJobs() async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('postedBy', isEqualTo: _auth.currentUser?.uid ?? '')
          .get();

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
          employerId: data['employerId'] ?? data['postedBy'] ?? '', // Fallback
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

      // Sort in-memory to avoid index requirement
      list.sort((a, b) => b.postedOn.compareTo(a.postedOn));
      return list;
    } catch (e) {
      debugPrint('[FirebaseService] Error getting employer jobs: $e');
      return [];
    }
  }

  /// Delete a job from Firebase
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
      debugPrint('[FirebaseService] Job deleted successfully: $jobId');
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting job: $e');
      rethrow;
    }
  }

  /// Get all available jobs for employees to browse
  Future<List<JobModel>> getAllJobs() async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'Open') // Matches web app "Open" status
          .get();

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
          employerId: data['employerId'] ?? '',
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

      // Sort in-memory to avoid index requirement
      list.sort((a, b) => b.postedOn.compareTo(a.postedOn));
      return list;
    } catch (e) {
      debugPrint('[FirebaseService] Error getting all jobs: $e');
      return [];
    }
  }

  /// Update a job in Firebase
  Future<void> updateJob(JobModel job) async {
    try {
      if (job.id.isEmpty) throw Exception('Job ID is missing');
      await _firestore.collection('jobs').doc(job.id).update({
        'title': job.title,
        'department': job.department,
        'category': job.category,
        'description': job.description,
        'requirements': job.requirements,
        'salaryRange': job.salaryRange,
        'companyName': job.companyName,
        'location': job.location,
        'jobType': job.jobType,
        'experienceLevel': job.experienceLevel,
        'skills': job.skills,
        'benefits': job.benefits,
        'status': job.status,
        'deadline': job.deadline != null ? Timestamp.fromDate(job.deadline!) : null,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('[FirebaseService] Job updated successfully: ${job.title}');
    } catch (e) {
      debugPrint('[FirebaseService] Error updating job: $e');
      rethrow;
    }
  }

  // ======== APPLICATION OPERATIONS ========

  /// Apply for a job
  Future<void> applyForJob(String jobId, String coverLetter) async {
    try {
      final employeeId = _auth.currentUser?.uid ?? '';
      //final employeeEmail = _auth.currentUser?.email ?? '';
      
      // Get job details for denormalized data
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      final jobData = jobDoc.data() as Map<String, dynamic>;
      
      final application = EmployeeApplicationModel(
        id: 'app_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: employeeId,
        jobId: jobId,
        jobTitle: jobData['title'] ?? '',
        companyName: jobData['companyName'] ?? '',
        postedBy: jobData['postedBy'] ?? '',
        status: ApplicationStatus.applied,
        appliedAt: DateTime.now(),
        coverLetter: coverLetter.isNotEmpty ? coverLetter : null,
      );

      await _firestore.collection('applications').add(application.toJson());
      
      // Update job application count
      await _firestore.collection('jobs').doc(jobId).update({
        'applicationCount': FieldValue.increment(1),
      });

      debugPrint('[FirebaseService] Job application submitted: ${jobData['title']}');
    } catch (e) {
      debugPrint('[FirebaseService] Error applying for job: $e');
      rethrow;
    }
  }

  /// Get applications for current employee
  Future<List<EmployeeApplicationModel>> getEmployeeApplications() async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('employeeId', isEqualTo: _auth.currentUser?.uid ?? '')
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EmployeeApplicationModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting employee applications: $e');
      return [];
    }
  }

  /// Get applications for employer's jobs
  Future<List<EmployeeApplicationModel>> getEmployerApplications() async {
    try {
      // Get all jobs by this employer
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('employerId', isEqualTo: _auth.currentUser?.uid ?? '')
          .get();

      final jobIds = jobsSnapshot.docs.map((doc) => doc.id).toList();

      if (jobIds.isEmpty) return [];

      // Get all applications for these jobs
      final applicationsSnapshot = await _firestore
          .collection('applications')
          .where('jobId', whereIn: jobIds)
          .orderBy('appliedAt', descending: true)
          .get();

      return applicationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return EmployeeApplicationModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting employer applications: $e');
      return [];
    }
  }

  /// Update application status
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status, {
    String? interviewDate,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status.value,
        'updatedAt': DateTime.now(),
      };

      if (interviewDate != null) {
        updateData['interviewDate'] = interviewDate;
      }

      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await _firestore.collection('applications').doc(applicationId).update(updateData);
      debugPrint('[FirebaseService] Application status updated: $status');
    } catch (e) {
      debugPrint('[FirebaseService] Error updating application status: $e');
      rethrow;
    }
  }

  // ======== PROFILE OPERATIONS ========

  /// Get employer profile
  Future<Map<String, dynamic>?> getEmployerProfile() async {
    try {
      final doc = await _firestore
          .collection('employers')
          .doc(_auth.currentUser?.uid ?? '')
          .get();
      
      return doc.data();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting employer profile: $e');
      return null;
    }
  }

  /// Get employee profile
  Future<Map<String, dynamic>?> getEmployeeProfile() async {
    try {
      final doc = await _firestore
          .collection('employees')
          .doc(_auth.currentUser?.uid ?? '')
          .get();
      
      return doc.data();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting employee profile: $e');
      return null;
    }
  }

  /// Update employer profile
  Future<void> updateEmployerProfile(Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('employers')
          .doc(_auth.currentUser?.uid ?? '')
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FirebaseService] Employer profile updated');
    } catch (e) {
      debugPrint('[FirebaseService] Error updating employer profile: $e');
      rethrow;
    }
  }

  /// Update employee profile
  Future<void> updateEmployeeProfile(Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('employees')
          .doc(_auth.currentUser?.uid ?? '')
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FirebaseService] Employee profile updated');
    } catch (e) {
      debugPrint('[FirebaseService] Error updating employee profile: $e');
      rethrow;
    }
  }
}
