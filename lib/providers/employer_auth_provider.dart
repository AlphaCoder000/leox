import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/session_service.dart';

class EmployerAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? get userId => _userId;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _verificationId;
  String? get verificationId => _verificationId;

  // ======== CONSTRUCTOR ========
  EmployerAuthProvider() {
    _initializeAuthState();
  }

  /// Initialize Firebase Auth state listener
  void _initializeAuthState() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _setLoggedIn(true, userId: user.uid, email: user.email);
        debugPrint('[EmployerAuthProvider] Firebase Auth state changed: User logged in');
      } else {
        _setLoggedIn(false);
        debugPrint('[EmployerAuthProvider] Firebase Auth state changed: User logged out');
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setLoggedIn(bool value, {String? userId, String? email}) {
    _isLoggedIn = value;
    _userId = userId;
    _userEmail = email;
    notifyListeners();
  }

  // 🔹 EMAIL LOGIN
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('[EmployerAuthProvider] Email login successful: ${credential.user?.email}');
      
      // Save session with real Firebase user data
      await SessionService.saveSession(
        role: "employer",
        userId: credential.user?.uid ?? "",
        email: credential.user?.email ?? "",
        authToken: await credential.user?.getIdToken() ?? "",
      );
      
      // Auth state listener will automatically update state
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No employer account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'Employer account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Try again later';
          break;
      }
      _setError(errorMessage);
      debugPrint('[EmployerAuthProvider] Email login error: ${e.code} - $errorMessage');
    } catch (e) {
      _setError('Login failed: $e');
      debugPrint('[EmployerAuthProvider] Unexpected email login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 SEND OTP
  Future<void> sendOtp(String phone) async {
    _setLoading(true);
    _setError(null);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          
          // Save session with Firebase user data
          final user = _auth.currentUser;
          if (user != null) {
            await SessionService.saveSession(
              role: "employer",
              userId: user.uid,
              email: user.email ?? "",
              authToken: await user.getIdToken() ?? "",
            );
          }
          
          debugPrint('[EmployerAuthProvider] Phone OTP verification successful');
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Phone verification failed';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many OTP requests. Try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded';
              break;
          }
          _setError(errorMessage);
          debugPrint('[EmployerAuthProvider] OTP send error: ${e.code} - $errorMessage');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
          debugPrint('[EmployerAuthProvider] OTP sent to $phone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('[EmployerAuthProvider] OTP auto-retrieval timeout');
        },
      );
    } catch (e) {
      _setError('Failed to send OTP: $e');
      debugPrint('[EmployerAuthProvider] Unexpected OTP send error: $e');
      _setLoading(false);
    }
  }

  // 🔹 VERIFY OTP
  Future<void> verifyOtp(String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Save session with Firebase user data
      final user = userCredential.user;
      if (user != null) {
        await SessionService.saveSession(
          role: "employer",
          userId: user.uid,
          email: user.email ?? "",
          authToken: await user.getIdToken() ?? "",
        );
      }

      debugPrint('[EmployerAuthProvider] OTP verification successful');
      
      // Clear verification ID after successful use
      _verificationId = null;
      
      // Auth state listener will automatically update state
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'OTP verification failed';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP code';
          break;
        case 'session-expired':
          errorMessage = 'OTP has expired. Please request a new one';
          break;
        case 'quota-exceeded':
          errorMessage = 'Too many failed attempts. Try again later';
          break;
      }
      _setError(errorMessage);
      debugPrint('[EmployerAuthProvider] OTP verification error: ${e.code} - $errorMessage');
    } catch (e) {
      _setError('OTP verification failed: $e');
      debugPrint('[EmployerAuthProvider] Unexpected OTP verification error: $e');
    } finally {
      _setLoading(false);
    }
  }

  
  // 🔹 GOOGLE LOGIN (TEMPORARILY DISABLED)
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implement Google Sign-In with correct API
      // For now, show error message
      _setError('Google Sign-In is temporarily disabled');
      debugPrint('[EmployerAuthProvider] Google Sign-In not yet implemented');
    } catch (e) {
      _setError('Google Sign-In failed: $e');
      debugPrint('[EmployerAuthProvider] Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ======== LOGOUT ========

  /// Logout employer user
  ///
  /// Clears Firebase Auth, session and local state
  Future<void> logout() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      // Clear local state
      _isLoggedIn = false;
      _userId = null;
      _userEmail = null;
      _verificationId = null;
      _errorMessage = null;
      
      // Clear session from SharedPreferences
      await SessionService.clearAuth();
      
      notifyListeners();

      debugPrint('[EmployerAuthProvider] User logged out successfully');
    } catch (e) {
      debugPrint('[EmployerAuthProvider] Logout error: $e');
      // Still clear local state even if Firebase logout fails
      _isLoggedIn = false;
      _userId = null;
      _userEmail = null;
      _verificationId = null;
      _errorMessage = null;
      await SessionService.clearAuth();
      notifyListeners();
    }
  }

  // ======== HELPERS ========

  /// Clear error message (call after showing error to UI)
  void clearError() {
    _setError(null);
  }

  /// Check if user has pending phone OTP (waiting for verification code)
  bool get isPendingOtpVerification =>
      _verificationId != null && _verificationId!.isNotEmpty;
}
