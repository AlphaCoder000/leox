import 'package:flutter/material.dart';

class EmployeeAuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // EMAIL LOGIN (dummy for now)
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _setLoading(false);
  }

  // PHONE OTP
  Future<void> sendOtp(String phone) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    _setLoading(false);
  }

  Future<void> verifyOtp(String otp) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _setLoading(false);
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
