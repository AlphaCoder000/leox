import 'package:flutter/material.dart';

class EmployeeDashboardProvider extends ChangeNotifier {
  int _applicationsSent = 0;
  int _activeApplications = 0;

  int get applicationsSent => _applicationsSent;
  int get activeApplications => _activeApplications;

  void applyForJob() {
    _applicationsSent++;
    _activeApplications++;
    notifyListeners();
  }

  void updateApplicationStatus({required bool isActive}) {
    if (!isActive && _activeApplications > 0) {
      _activeApplications--;
      notifyListeners();
    }
  }
}
