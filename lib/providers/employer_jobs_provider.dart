import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';

class EmployerJobsProvider extends ChangeNotifier {
  final List<JobModel> _jobs = [];

  List<JobModel> get jobs => _jobs;

  void addJob(JobModel job) {
    _jobs.add(job);
    notifyListeners();
  }

  void deleteJob(JobModel job) {
    _jobs.remove(job);
    notifyListeners();
  }

  void updateJob(JobModel oldJob, JobModel updatedJob) {
    final index = _jobs.indexOf(oldJob);
    if (index != -1) {
      _jobs[index] = updatedJob;
      notifyListeners();
    }
  }
}
