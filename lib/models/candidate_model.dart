import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:leox/models/job_application_model.dart';
import 'package:leox/models/employee_application_model.dart';

class CandidateModel {
  final String id;
  final DateTime appliedAt;
  final String avatarUrl;
  final String email;
  final String jobAppliedFor; // Job ID
  final String employeeId; // Reference to employee UID
  final String employerId; // Added to enable filtering for employers
  final String matchReasoning;
  final double matchScore;
  final String name;
  final String phone;
  final String resumeText;
  final String resumeUrl;
  final List<String> skills;
  final String status;
  final String coverLetter;
  final String jobTitle;
  final String jobDepartment;
  final String jobType;
  final String jobLocation;
  final String headline;
  final String experience;
  final String expectedSalary;
  final String availability;
  final String linkedIn;
  final String portfolio;

  CandidateModel({
    required this.id,
    required this.appliedAt,
    required this.avatarUrl,
    required this.email,
    required this.jobAppliedFor,
    required this.employeeId,
    required this.employerId,
    this.matchReasoning = 'AI analysis not performed.',
    this.matchScore = 0.0,
    required this.name,
    required this.phone,
    this.resumeText = '',
    required this.resumeUrl,
    required this.skills,
    this.status = 'pending',
    this.coverLetter = '',
    this.jobTitle = '',
    this.jobDepartment = '',
    this.jobType = '',
    this.jobLocation = '',
    this.headline = '',
    this.experience = '',
    this.expectedSalary = '',
    this.availability = '',
    this.linkedIn = '',
    this.portfolio = '',
  });

  factory CandidateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateModel(
      id: doc.id,
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] ?? '',
      email: data['email'] ?? '',
      jobAppliedFor: data['jobAppliedFor'] ?? '',
      employeeId: data['employeeId'] ?? '',
      employerId: data['employerId'] ?? '',
      matchReasoning: data['matchReasoning'] ?? '',
      matchScore: (data['matchScore'] ?? 0).toDouble(),
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      resumeText: data['resumeText'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      status: data['status'] ?? 'pending',
      coverLetter: data['coverLetter'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      jobDepartment: data['jobDepartment'] ?? '',
      jobType: data['jobType'] ?? '',
      jobLocation: data['jobLocation'] ?? '',
      headline: data['headline'] ?? '',
      experience: data['experience'] ?? '',
      expectedSalary: data['expectedSalary'] ?? '',
      availability: data['availability'] ?? '',
      linkedIn: data['linkedIn'] ?? '',
      portfolio: data['portfolio'] ?? '',
    );
  }

  factory CandidateModel.fromJobApplication(JobApplicationModel app) {
    return CandidateModel(
      id: app.id,
      appliedAt: app.appliedAt,
      avatarUrl: app.employeeProfilePicture,
      email: app.employeeEmail,
      jobAppliedFor: app.jobId,
      employeeId: app.employeeId,
      employerId: app.employerId,
      name: app.employeeName,
      phone: app.employeePhone,
      resumeUrl: app.resumeUrl ?? '',
      skills: app.employeeSkills,
      status: app.status,
      coverLetter: app.coverLetter,
      jobTitle: app.jobTitle,
      jobDepartment: app.jobDepartment,
      jobType: app.jobType,
      jobLocation: app.jobLocation,
      headline: app.employeeHeadline,
      matchScore: app.matchScore,
      matchReasoning: app.matchReasoning,
      experience: app.experience,
      expectedSalary: app.expectedSalary,
      availability: app.availability,
      linkedIn: app.linkedIn,
      portfolio: app.portfolio,
    );
  }

  factory CandidateModel.fromEmployeeApplication(EmployeeApplicationModel app) {
    return CandidateModel(
      id: app.id,
      appliedAt: app.appliedAt,
      avatarUrl: '', // Not available in EmployeeApplicationModel
      email: '', // Not available
      jobAppliedFor: app.jobId,
      employeeId: app.employeeId, // Added properly
      employerId: '', // Not available
      name: 'Applicant',
      phone: '',
      resumeUrl: '',
      skills: [],
      status: app.status.value,
      coverLetter: app.coverLetter ?? '',
      jobTitle: app.jobTitle,
      jobType: '',
      jobLocation: '',
      headline: '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appliedAt': Timestamp.fromDate(appliedAt),
      'avatarUrl': avatarUrl,
      'email': email,
      'jobAppliedFor': jobAppliedFor,
      'employeeId': employeeId,
      'employerId': employerId,
      'matchReasoning': matchReasoning,
      'matchScore': matchScore,
      'name': name,
      'phone': phone,
      'resumeText': resumeText,
      'resumeUrl': resumeUrl,
      'skills': skills,
      'status': status,
      'coverLetter': coverLetter,
      'jobTitle': jobTitle,
      'jobDepartment': jobDepartment,
      'jobType': jobType,
      'jobLocation': jobLocation,
      'headline': headline,
      'experience': experience,
      'expectedSalary': expectedSalary,
      'availability': availability,
      'linkedIn': linkedIn,
      'portfolio': portfolio,
    };
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

  CandidateModel copyWith({
    String? id,
    DateTime? appliedAt,
    String? avatarUrl,
    String? email,
    String? jobAppliedFor,
    String? employeeId,
    String? employerId,
    String? matchReasoning,
    double? matchScore,
    String? name,
    String? phone,
    String? resumeText,
    String? resumeUrl,
    List<String>? skills,
    String? status,
    String? coverLetter,
    String? jobTitle,
    String? jobDepartment,
    String? jobType,
    String? jobLocation,
    String? headline,
    String? experience,
    String? expectedSalary,
    String? availability,
    String? linkedIn,
    String? portfolio,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      appliedAt: appliedAt ?? this.appliedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      jobAppliedFor: jobAppliedFor ?? this.jobAppliedFor,
      employeeId: employeeId ?? this.employeeId,
      employerId: employerId ?? this.employerId,
      matchReasoning: matchReasoning ?? this.matchReasoning,
      matchScore: matchScore ?? this.matchScore,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      resumeText: resumeText ?? this.resumeText,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      skills: skills ?? this.skills,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      jobTitle: jobTitle ?? this.jobTitle,
      jobDepartment: jobDepartment ?? this.jobDepartment,
      jobType: jobType ?? this.jobType,
      jobLocation: jobLocation ?? this.jobLocation,
      headline: headline ?? this.headline,
      experience: experience ?? this.experience,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      availability: availability ?? this.availability,
      linkedIn: linkedIn ?? this.linkedIn,
      portfolio: portfolio ?? this.portfolio,
    );
  }
}
