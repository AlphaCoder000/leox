class CandidateModel {
  final String name;
  final String email;
  final String appliedJobTitle;
  final String status; // Applied, Shortlisted, Rejected, Hired
  final DateTime appliedOn;

  CandidateModel({
    required this.name,
    required this.email,
    required this.appliedJobTitle,
    required this.status,
    required this.appliedOn,
  });
}
