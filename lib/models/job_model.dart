import 'candidate_model.dart';

class JobModel {
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
    required this.title,
    required this.department,
    required this.category,
    required this.description,
    required this.requirements,
    required this.postedOn,
    this.employerId = '',
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

  @override
  String toString() {
    return 'JobModel(title: $title, company: $companyName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobModel && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}