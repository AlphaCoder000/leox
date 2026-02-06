import 'package:flutter/material.dart';

class EmployerDashboardProvider extends ChangeNotifier {
  int totalJobs = 0;
  int totalCandidates = 0;
  int shortlisted = 0;
  int hired = 0;

  void loadDummyData() {
    totalJobs = 5;
    totalCandidates = 24;
    shortlisted = 6;
    hired = 2;
    notifyListeners();
  }
}
