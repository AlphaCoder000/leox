import 'package:flutter/material.dart';
import '../models/candidate_model.dart';

class EmployerCandidatesProvider extends ChangeNotifier {
  final List<CandidateModel> _candidates = [];

  List<CandidateModel> get candidates => _candidates;

  void addCandidate(CandidateModel candidate) {
    _candidates.add(candidate);
    notifyListeners();
  }

  void removeCandidate(CandidateModel candidate) {
    _candidates.remove(candidate);
    notifyListeners();
  }

  List<CandidateModel> candidatesForJob(String jobTitle) {
    return _candidates.where((c) => c.appliedJobTitle == jobTitle).toList();
  }
}
