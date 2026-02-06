import 'package:flutter/material.dart';
import '../models/job_model.dart';

class EmployerJobsProvider extends ChangeNotifier {
  final List<JobModel> _jobs = [];

  List<JobModel> get jobs => _jobs;

  void addJob(JobModel job) {
    _jobs.add(job);
    notifyListeners();
  }
}
