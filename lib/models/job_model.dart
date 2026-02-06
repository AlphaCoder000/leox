class JobModel {
  final String title;
  final String department;
  final String category;
  final String description;
  final List<String> requirements;
  final DateTime postedOn;

  JobModel({
    required this.title,
    required this.department,
    required this.category,
    required this.description,
    required this.requirements,
    required this.postedOn,
  });
}
