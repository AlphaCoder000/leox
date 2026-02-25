/// Job Application Model
///
/// Represents a job application submitted by an employee to a job posting
library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  // ======== NEW FIELDS FOR MATCHING SCORING ========
  final double matchScore;
  final String matchReasoning;

  // ======== ADDITIONAL CANDIDATE DETAILS ========
  final String experience;
  final String expectedSalary;
  final String availability;
  final String linkedIn;
  final String portfolio;

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
    this.matchScore = 0.0,
    this.matchReasoning = 'AI analysis not performed.',
    this.experience = '',
    this.expectedSalary = '',
    this.availability = '',
    this.linkedIn = '',
    this.portfolio = '',
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
      matchScore: (data['matchScore'] ?? 0.0).toDouble(),
      matchReasoning: data['matchReasoning'] ?? 'AI analysis not performed.',
      experience: data['experience'] ?? '',
      expectedSalary: data['expectedSalary'] ?? '',
      availability: data['availability'] ?? '',
      linkedIn: data['linkedIn'] ?? '',
      portfolio: data['portfolio'] ?? '',
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
      'matchScore': matchScore,
      'matchReasoning': matchReasoning,
      'experience': experience,
      'expectedSalary': expectedSalary,
      'availability': availability,
      'linkedIn': linkedIn,
      'portfolio': portfolio,
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
    double? matchScore,
    String? matchReasoning,
    String? experience,
    String? expectedSalary,
    String? availability,
    String? linkedIn,
    String? portfolio,
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
      matchScore: matchScore ?? this.matchScore,
      matchReasoning: matchReasoning ?? this.matchReasoning,
      experience: experience ?? this.experience,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      availability: availability ?? this.availability,
      linkedIn: linkedIn ?? this.linkedIn,
      portfolio: portfolio ?? this.portfolio,
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

  /// Get status color as a Flutter Color object
  Color statusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'shortlisted':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      case 'hired':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Get status display text (Method version)
  String statusLabel() => statusDisplay;

  /// Get relative time description
  String statusWithDays() {
    final diff = DateTime.now().difference(appliedAt);
    if (diff.inDays == 0) return 'Applied Today';
    if (diff.inDays == 1) return 'Applied Yesterday';
    if (diff.inDays < 30) return 'Applied ${diff.inDays} days ago';
    return 'Applied on ${appliedAt.day}/${appliedAt.month}/${appliedAt.year}';
  }
}
