import 'package:flutter/material.dart';
import '../../models/job_model.dart';

class EmployeeJobsProvider extends ChangeNotifier {
  final List<JobModel> _jobs = [
    JobModel(
      title: "Senior Frontend Engineer",
      department: "Engineering",
      category: "Not specified",
      description: "We are looking for an experienced frontend engineer...",
      postedOn: DateTime(2025, 11, 11),
      postedBy: "Anand Kumar",
      status: "Open",
      requirements: ["Must be in this field for about 2 years"],
    ),
  ];

  List<JobModel> get jobs => _jobs;

  List<JobModel> search(String query) {
    if (query.isEmpty) return _jobs;
    return _jobs
        .where(
          (j) =>
              j.title.toLowerCase().contains(query.toLowerCase()) ||
              j.department.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
