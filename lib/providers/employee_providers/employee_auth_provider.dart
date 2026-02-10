import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/employee_api_service.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class EmployeeAuthProvider extends ChangeNotifier {
  // ======== FIREBASE AUTH ========
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;

  // ======== STATE ========
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

  String? _verificationId; // For phone OTP flow
  String? get verificationId => _verificationId;

  // ======== CONSTRUCTOR ========
  EmployeeAuthProvider() {
    _initializeAuthState();
  }

  /// Initialize Firebase Auth state listener
  void _initializeAuthState() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _setLoggedIn(true, userId: user.uid, email: user.email);
        debugPrint('[EmployeeAuthProvider] Firebase Auth state changed: User logged in');
      } else {
        _setLoggedIn(false);
        debugPrint('[EmployeeAuthProvider] Firebase Auth state changed: User logged out');
      }
    });
  }

  // ======== PRIVATE METHODS ========
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

  // ======== REGISTRATION ========

  /// Register with email and password
  ///
  /// Calls: POST /auth/employee/register-email
  /// On success: Saves session and sets logged in state
  /// On error: Sets error message for UI display
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Call API
      final response = await EmployeeApiService.registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // LOG: Registration successful
      debugPrint('[EmployeeAuthProvider] Registration successful for: $email');

      // Get ID and token from response
      final userId = response['id'] ?? response['userId'] ?? '';
      final authToken =
          response['token'] ?? response['authToken'] ?? 'temp_token';

      // Save to session
      await SessionService.saveSession(
        role: 'employee',
        userId: userId,
        email: email,
        authToken: authToken,
        refreshToken: response['refreshToken'],
      );

      // Update local state
      _setLoggedIn(true, userId: userId, email: email);

      debugPrint('[EmployeeAuthProvider] Session saved, user logged in');
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeAuthProvider] Registration error: ${e.message}');
    } catch (e) {
      _setError('Registration failed: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Register with phone (initiate OTP flow)
  ///
  /// Calls: POST /auth/employee/register-phone
  /// On success: Stores verification ID for next step (confirm OTP)
  /// On error: Sets error message
  Future<void> registerWithPhone({
    required String phone,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await EmployeeApiService.registerWithPhone(
        phone: phone,
        firstName: firstName,
        lastName: lastName,
      );

      // LOG: OTP sent successfully
      debugPrint('[EmployeeAuthProvider] OTP sent to phone: $phone');

      // Store verification ID for next step
      _verificationId = response['phoneVerificationId'];

      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeAuthProvider] Phone registration error: ${e.message}');
    } catch (e) {
      _setError('Failed to send OTP: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ======== LOGIN ========

  /// Login with email and password
  ///
  /// Calls: POST /auth/employee/login-email
  /// On success: Saves session and sets logged in state
  /// On error: Sets error message for UI display
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      // Call API
      final response = await EmployeeApiService.loginWithEmail(
        email: email,
        password: password,
      );

      // LOG: Login successful
      debugPrint('[EmployeeAuthProvider] Login successful for: $email');

      // Get ID and token from response
      final userId = response['id'] ?? response['userId'] ?? '';
      final authToken =
          response['token'] ?? response['authToken'] ?? 'temp_token';

      // Save to session
      await SessionService.saveSession(
        role: 'employee',
        userId: userId,
        email: email,
        authToken: authToken,
        refreshToken: response['refreshToken'],
      );

      // Update local state
      _setLoggedIn(true, userId: userId, email: email);

      debugPrint('[EmployeeAuthProvider] Session saved, user logged in');
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeAuthProvider] Login error: ${e.message}');
    } catch (e) {
      _setError('Login failed: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ======== OTP FLOW ========

  /// Send OTP to phone for login
  ///
  /// Calls: POST /auth/employee/send-otp
  /// On success: Stores verification ID for verification step
  /// On error: Sets error message
  Future<void> sendOtp(String phone) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await EmployeeApiService.sendLoginOtp(phone: phone);

      // LOG: OTP sent successfully
      debugPrint('[EmployeeAuthProvider] OTP sent to phone: $phone');

      // Store verification ID for next step (verification)
      _verificationId = response['phoneVerificationId'];

      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeAuthProvider] Send OTP error: ${e.message}');
    } catch (e) {
      _setError('Failed to send OTP: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP code (for login/registration)
  ///
  /// Note: This can be used for both login and registration depending on flow
  /// For registration: Use with phone and _verificationId from registerWithPhone()
  /// For login: Will be handled in Task 9
  Future<void> verifyOtp({required String phone, required String otp}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await EmployeeApiService.verifyOtp(
        phone: phone,
        otp: otp,
        phoneVerificationId: _verificationId,
      );

      // LOG: OTP verification successful
      debugPrint('[EmployeeAuthProvider] OTP verified for phone: $phone');

      // Get ID and token from response
      final userId = response['id'] ?? response['userId'] ?? '';
      final authToken =
          response['token'] ?? response['authToken'] ?? 'temp_token';
      final userEmail = response['email'] ?? '';

      // Save to session
      await SessionService.saveSession(
        role: 'employee',
        userId: userId,
        email: userEmail.isNotEmpty ? userEmail : phone,
        authToken: authToken,
        refreshToken: response['refreshToken'],
      );

      // Update local state
      _setLoggedIn(true, userId: userId, email: userEmail);

      // Clear verification ID after successful use
      _verificationId = null;

      debugPrint('[EmployeeAuthProvider] Session saved via OTP, user logged in');
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeAuthProvider] OTP verification error: ${e.message}');
    } catch (e) {
      _setError('OTP verification failed: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ======== LOGOUT ========

  /// Logout the user
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

      debugPrint('[EmployeeAuthProvider] User logged out successfully');
    } catch (e) {
      debugPrint('[EmployeeAuthProvider] Logout error: $e');
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

  // ======== FIREBASE AUTH METHODS ========

  /// Sign in with Firebase Auth (Email/Password)
  Future<void> signInWithFirebase({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('[EmployeeAuthProvider] Firebase Auth sign in successful: ${credential.user?.email}');
      
      // The auth state listener will automatically update the state
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'User account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Try again later';
          break;
      }
      _setError(errorMessage);
      debugPrint('[EmployeeAuthProvider] Firebase Auth error: ${e.code} - $errorMessage');
    } catch (e) {
      _setError('Authentication failed: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected Firebase Auth error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Register with Firebase Auth (Email/Password)
  Future<void> registerWithFirebase({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name
      await credential.user?.updateDisplayName('$firstName $lastName');

      debugPrint('[EmployeeAuthProvider] Firebase Auth registration successful: ${credential.user?.email}');
      
      // The auth state listener will automatically update the state
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
      }
      _setError(errorMessage);
      debugPrint('[EmployeeAuthProvider] Firebase Auth registration error: ${e.code} - $errorMessage');
    } catch (e) {
      _setError('Registration failed: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected Firebase Auth registration error: $e');
    } finally {
      _setLoading(false);
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
