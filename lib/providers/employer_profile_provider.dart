import 'package:flutter/material.dart';
import '../models/employer_profile_model.dart';

class EmployerProfileProvider extends ChangeNotifier {
  EmployerProfileModel _profile = EmployerProfileModel(
    name: "Admin",
    email: "akashmore.scoe.comp@gmail.com",
    phone: "",
    companyName: "",
  );

  EmployerProfileModel get profile => _profile;

  void updateProfile({
    required String name,
    required String phone,
    required String companyName,
  }) {
    _profile.name = name;
    _profile.phone = phone;
    _profile.companyName = companyName;
    notifyListeners();
  }

  void deleteAccount() {
    // 🔴 Later: Firebase delete user + Firestore cleanup
    _profile = EmployerProfileModel(
      name: "",
      email: "",
      phone: "",
      companyName: "",
    );
    notifyListeners();
  }
}
