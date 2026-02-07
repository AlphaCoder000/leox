import 'candidate_model.dart';

class JobModel {
  final String title;
  final String department;
  final String category;
  final String description;
  final List<String> requirements;
  final DateTime postedOn;

  // Already added
  final List<CandidateModel> candidates;

  // 👇 NEW OPTIONAL FIELDS (SAFE)
  final String status; // Open / Closed
  final String postedBy; // Employer name
  final String companyName; // Optional

  JobModel({
    required this.title,
    required this.department,
    required this.category,
    required this.description,
    required this.requirements,
    required this.postedOn,

    this.candidates = const [],

    // 👇 defaults ensure ZERO breakage
    this.status = "Open",
    this.postedBy = "",
    this.companyName = "",
  });
}
