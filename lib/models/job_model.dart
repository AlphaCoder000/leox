import 'candidate_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String department;
  final String category;
  final String description;
  final List<String> requirements;
  final DateTime postedOn;
  final String employerId;
  final String companyName;
  final String location;
  final String jobType; // full-time, part-time, contract, internship
  final String experienceLevel; // entry, mid, senior, executive
  final String salaryRange;
  final List<String> skills;
  final List<String> benefits;
  final String status; // active, inactive, closed
  final String postedBy;
  final int applicationCount;
  final DateTime? deadline;
  final Map<String, dynamic> additionalInfo;

  // Already added
  final List<CandidateModel> candidates;

  JobModel({
    this.id = '',
    required this.title,
    required this.department,
    required this.category,
    required this.description,
    required this.requirements,
    required this.postedOn,
    this.employerId = '', // Made optional with default empty string
    this.companyName = '',
    this.location = '',
    this.jobType = 'full-time',
    this.experienceLevel = 'entry',
    this.salaryRange = '',
    this.skills = const [],
    this.benefits = const [],
    this.status = 'active',
    this.postedBy = '',
    this.applicationCount = 0,
    this.deadline,
    this.additionalInfo = const {},
    this.candidates = const [],
  });

  // Factory constructor from Firestore
  factory JobModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return JobModel(
      id: documentId,
      title: data['title'] ?? '',
      department: data['department'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      postedOn: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      employerId: data['employerId'] ?? '',
      companyName: data['companyName'] ?? '',
      location: data['location'] ?? '',
      jobType: data['jobType'] ?? 'full-time',
      experienceLevel: data['experienceLevel'] ?? 'entry',
      salaryRange: data['salaryRange'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      status: data['status'] ?? 'active',
      postedBy: data['postedBy'] ?? '',
      applicationCount: data['applicationCount'] ?? 0,
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      additionalInfo: data['additionalInfo'] ?? {},
      candidates: [], // Candidates loaded separately
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'department': department,
      'category': category,
      'description': description,
      'requirements': requirements,
      'postedAt': Timestamp.fromDate(postedOn),
      'employerId': employerId,
      'companyName': companyName,
      'location': location,
      'jobType': jobType,
      'experienceLevel': experienceLevel,
      'salaryRange': salaryRange,
      'skills': skills,
      'benefits': benefits,
      'status': status,
      'postedBy': postedBy,
      'applicationCount': applicationCount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'additionalInfo': additionalInfo,
      'updatedAt': Timestamp.now(),
    };
  }

  // Copy with method
  JobModel copyWith({
    String? id,
    String? title,
    String? department,
    String? category,
    String? description,
    List<String>? requirements,
    DateTime? postedOn,
    String? employerId,
    String? companyName,
    String? location,
    String? jobType,
    String? experienceLevel,
    String? salaryRange,
    List<String>? skills,
    List<String>? benefits,
    String? status,
    String? postedBy,
    int? applicationCount,
    DateTime? deadline,
    Map<String, dynamic>? additionalInfo,
    List<CandidateModel>? candidates,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      department: department ?? this.department,
      category: category ?? this.category,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      postedOn: postedOn ?? this.postedOn,
      employerId: employerId ?? this.employerId,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryRange: salaryRange ?? this.salaryRange,
      skills: skills ?? this.skills,
      benefits: benefits ?? this.benefits,
      status: status ?? this.status,
      postedBy: postedBy ?? this.postedBy,
      applicationCount: applicationCount ?? this.applicationCount,
      deadline: deadline ?? this.deadline,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      candidates: candidates ?? this.candidates,
    );
  }

  @override
  String toString() {
    return 'JobModel(id: $id, title: $title, company: $companyName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
