/// Job Application Model
///
/// Represents a job application submitted by an employee to a job posting
library;
import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplicationModel {
  // ======== APPLICATION INFO ========
  final String id;
  final String jobId; // Reference to job posting
  final String employeeId; // Reference to employee
  final String employerId; // Reference to employer
  final String status; // 'pending', 'reviewed', 'shortlisted', 'rejected', 'hired'
  
  // ======== APPLICATION DETAILS ========
  final String coverLetter;
  final String? resumeUrl; // URL to uploaded resume (optional)
  final String? resumeName; // Original resume file name (optional)
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // Employer ID who reviewed
  
  // ======== CANDIDATE INFO (cached for quick access) ========
  final String employeeName;
  final String employeeEmail;
  final String employeePhone;
  final String employeeProfilePicture;
  final List<String> employeeSkills;
  final String employeeHeadline;
  
  // ======== JOB INFO (cached for quick access) ========
  final String jobTitle;
  final String jobDepartment;
  final String companyName;
  final String jobType; // 'full-time', 'part-time', 'contract', 'internship'
  final String jobLocation;
  final String salary;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.employeeId,
    required this.employerId,
    this.status = 'pending',
    required this.coverLetter,
    this.resumeUrl, // Optional
    this.resumeName, // Optional
    required this.appliedAt,
    this.reviewedAt,
    this.reviewedBy,
    required this.employeeName,
    required this.employeeEmail,
    this.employeePhone = '',
    this.employeeProfilePicture = '',
    this.employeeSkills = const [],
    this.employeeHeadline = '',
    required this.jobTitle,
    this.jobDepartment = '',
    this.companyName = '',
    this.jobType = '',
    this.jobLocation = '',
    this.salary = '',
  });

  /// Create from Firestore document
  factory JobApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return JobApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      employeeId: data['employeeId'] ?? '',
      employerId: data['employerId'] ?? '',
      status: data['status'] ?? 'pending',
      coverLetter: data['coverLetter'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      resumeName: data['resumeName'] ?? '',
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null 
          ? (data['reviewedAt'] as Timestamp).toDate() 
          : null,
      reviewedBy: data['reviewedBy'],
      employeeName: data['employeeName'] ?? '',
      employeeEmail: data['employeeEmail'] ?? '',
      employeePhone: data['employeePhone'] ?? '',
      employeeProfilePicture: data['employeeProfilePicture'] ?? '',
      employeeSkills: List<String>.from(data['employeeSkills'] ?? []),
      employeeHeadline: data['employeeHeadline'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      jobDepartment: data['jobDepartment'] ?? '',
      companyName: data['companyName'] ?? '',
      jobType: data['jobType'] ?? '',
      jobLocation: data['jobLocation'] ?? '',
      salary: data['salary'] ?? '',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'employeeId': employeeId,
      'employerId': employerId,
      'status': status,
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
      'resumeName': resumeName,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'reviewedAt': reviewedAt != null 
          ? Timestamp.fromDate(reviewedAt!) 
          : null,
      'reviewedBy': reviewedBy,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'employeePhone': employeePhone,
      'employeeProfilePicture': employeeProfilePicture,
      'employeeSkills': employeeSkills,
      'employeeHeadline': employeeHeadline,
      'jobTitle': jobTitle,
      'jobDepartment': jobDepartment,
      'companyName': companyName,
      'jobType': jobType,
      'jobLocation': jobLocation,
      'salary': salary,
    };
  }

  /// Create a copy with modified fields
  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? employeeId,
    String? employerId,
    String? status,
    String? coverLetter,
    String? resumeUrl,
    String? resumeName,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? employeeName,
    String? employeeEmail,
    String? employeePhone,
    String? employeeProfilePicture,
    List<String>? employeeSkills,
    String? employeeHeadline,
    String? jobTitle,
    String? jobDepartment,
    String? companyName,
    String? jobType,
    String? jobLocation,
    String? salary,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      employeeId: employeeId ?? this.employeeId,
      employerId: employerId ?? this.employerId,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeName: resumeName ?? this.resumeName,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeePhone: employeePhone ?? this.employeePhone,
      employeeProfilePicture: employeeProfilePicture ?? this.employeeProfilePicture,
      employeeSkills: employeeSkills ?? this.employeeSkills,
      employeeHeadline: employeeHeadline ?? this.employeeHeadline,
      jobTitle: jobTitle ?? this.jobTitle,
      jobDepartment: jobDepartment ?? this.jobDepartment,
      companyName: companyName ?? this.companyName,
      jobType: jobType ?? this.jobType,
      jobLocation: jobLocation ?? this.jobLocation,
      salary: salary ?? this.salary,
    );
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'reviewed':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      case 'hired':
        return 'Hired';
      default:
        return status;
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'reviewed':
        return '#2196F3'; // Blue
      case 'shortlisted':
        return '#4CAF50'; // Green
      case 'rejected':
        return '#F44336'; // Red
      case 'hired':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }
}
