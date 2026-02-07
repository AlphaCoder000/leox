import 'package:flutter/material.dart';

class EmployeeProfileProvider extends ChangeNotifier {
  String name = "Akash More";
  String email = "akashmoreasm6000@gmail.com";
  String phone = "9156862656";
  String location = "";
  String resumePath = "";
  List<String> skills = [];

  void updateProfile({
    required String name,
    required String phone,
    required String location,
  }) {
    this.name = name;
    this.phone = phone;
    this.location = location;
    notifyListeners();
  }

  void uploadResume(String path) {
    resumePath = path;
    // later: extract skills automatically
    notifyListeners();
  }

  void deleteAccount() {
    // Firebase delete later
  }
}
