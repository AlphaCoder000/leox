//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import '../services/session_service.dart';

class EmployerAuthProvider extends ChangeNotifier {
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? verificationId;

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  // 🔹 EMAIL LOGIN
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    //await _auth.signInWithEmailAndPassword(email: email, password: password);
    await SessionService.saveSession("employer");
    _setLoading(false);
  }

  // 🔹 SEND OTP
  Future<void> sendOtp(String phone) async {
    _setLoading(true);
    /*
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (cred) async {
        await _auth.signInWithCredential(cred);
        await SessionService.saveSession("employer");
      },
      verificationFailed: (e) {
        _setLoading(false);
        throw e;
      },
      codeSent: (id, _) {
        verificationId = id;
        _setLoading(false);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    */
  }

  // 🔹 VERIFY OTP
  Future<void> verifyOtp(String otp) async {
    _setLoading(true);
    /*
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp,
    );
    */
   // await _auth.signInWithCredential(cred);
    await SessionService.saveSession("employer");
    _setLoading(false);
    
  }

  /*
  // 🔹 GOOGLE LOGIN
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    await SessionService.saveSession("employer");
    _setLoading(false);
  }
  */
}
