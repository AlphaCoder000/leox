/// Job Posting Model
///
/// Represents a job posting created by an employer
library;
import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostingModel {
  // ======== BASIC INFO ========
  final String id;
  final String title;
  final String department;
  final String category;
  final String description;
  final String employerId;
  final String companyName;
  final String location;
  
  // ======== JOB DETAILS ========
  final String jobType; // 'full-time', 'part-time', 'contract', 'internship'
  final String experienceLevel; // 'entry', 'mid', 'senior', 'executive'
  final String salary;
  final List<String> requirements;
  final List<String> skills;
  final List<String> benefits;
  
  // ======== STATUS & TIMING ========
  final String status; // 'active', 'inactive', 'closed'
  final DateTime postedAt;
  final DateTime? deadline;
  final int applicationCount;
  
  // ======== ADDITIONAL INFO ========
  final Map<String, dynamic> additionalInfo;

  JobPostingModel({
    required this.id,
    required this.title,
    required this.department,
    this.category = '',
    required this.description,
    required this.employerId,
    required this.companyName,
    required this.location,
    required this.jobType,
    this.experienceLevel = 'entry',
    required this.salary,
    this.requirements = const [],
    this.skills = const [],
    this.benefits = const [],
    this.status = 'active',
    required this.postedAt,
    this.deadline,
    this.applicationCount = 0,
    this.additionalInfo = const {},
  });

  /// Create from Firestore document
  factory JobPostingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return JobPostingModel(
      id: doc.id,
      title: data['title'] ?? '',
      department: data['department'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      employerId: data['employerId'] ?? data['postedBy'] ?? '',
      companyName: data['companyName'] ?? '',
      location: data['location'] ?? '',
      jobType: data['jobType'] ?? '',
      experienceLevel: data['experienceLevel'] ?? 'entry',
      salary: data['salary'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      status: data['status'] ?? 'active',
      postedAt: (data['postedAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null 
          ? (data['deadline'] as Timestamp).toDate() 
          : null,
      applicationCount: data['applicationCount'] ?? 0,
      additionalInfo: data['additionalInfo'] ?? {},
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'department': department,
      'category': category,
      'description': description,
      'employerId': employerId,
      'companyName': companyName,
      'location': location,
      'jobType': jobType,
      'experienceLevel': experienceLevel,
      'salary': salary,
      'requirements': requirements,
      'skills': skills,
      'benefits': benefits,
      'status': status,
      'postedAt': Timestamp.fromDate(postedAt),
      'deadline': deadline != null 
          ? Timestamp.fromDate(deadline!) 
          : null,
      'applicationCount': applicationCount,
      'additionalInfo': additionalInfo,
    };
  }

  /// Create a copy with modified fields
  JobPostingModel copyWith({
    String? id,
    String? title,
    String? department,
    String? category,
    String? description,
    String? employerId,
    String? companyName,
    String? location,
    String? jobType,
    String? experienceLevel,
    String? salary,
    List<String>? requirements,
    List<String>? skills,
    List<String>? benefits,
    String? status,
    DateTime? postedAt,
    DateTime? deadline,
    int? applicationCount,
    Map<String, dynamic>? additionalInfo,
  }) {
    return JobPostingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      department: department ?? this.department,
      category: category ?? this.category,
      description: description ?? this.description,
      employerId: employerId ?? this.employerId,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salary: salary ?? this.salary,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      benefits: benefits ?? this.benefits,
      status: status ?? this.status,
      postedAt: postedAt ?? this.postedAt,
      deadline: deadline ?? this.deadline,
      applicationCount: applicationCount ?? this.applicationCount,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  /// Get job type display text
  String get jobTypeDisplay {
    switch (jobType) {
      case 'full-time':
        return 'Full Time';
      case 'part-time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      default:
        return jobType;
    }
  }

  /// Get experience level display text
  String get experienceLevelDisplay {
    switch (experienceLevel) {
      case 'entry':
        return 'Entry Level';
      case 'mid':
        return 'Mid Level';
      case 'senior':
        return 'Senior Level';
      case 'executive':
        return 'Executive Level';
      default:
        return experienceLevel;
    }
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  /// Check if job is still accepting applications
  bool get isAcceptingApplications {
    if (status != 'active') return false;
    if (deadline != null && deadline!.isBefore(DateTime.now())) return false;
    return true;
  }

  /// Get days since posting
  int get daysSincePosting {
    return DateTime.now().difference(postedAt).inDays;
  }

  /// Get days until deadline
  int? get daysUntilDeadline {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  /// Check if deadline is approaching
  bool get isDeadlineApproaching {
    if (deadline == null) return false;
    final daysLeft = daysUntilDeadline!;
    return daysLeft <= 7 && daysLeft >= 0;
  }

  /// Check if deadline has passed
  bool get isDeadlinePassed {
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }
}
