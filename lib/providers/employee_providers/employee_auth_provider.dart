import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leox/services/session_service.dart';

class EmployeeAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Updated to match google-services.json Web Client ID
    clientId: '340682426505-q2q1h7ooeua23piinorknvbcu0scma06.apps.googleusercontent.com', 
    scopes: ['email', 'profile'],
  );

  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _userId;
  String? get userId => _userId;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _verificationId;
  String? get verificationId => _verificationId;

  // ======== CONSTRUCTOR ========
  EmployeeAuthProvider() {
    _initializeAuthState();
  }

  /// Initialize Firebase Auth state listener
  void _initializeAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      debugPrint('[EmployeeAuthProvider] Auth state changed: ${user?.uid}');
      
      if (user != null) {
        // Quick login without Firestore check for better performance
        _setLoggedIn(true);
        _firebaseUser = user;
        _userId = user.uid;
        _userEmail = user.email;
        
        // Background role check (non-blocking)
        _firestore.collection('users').doc(user.uid).get().then((userDoc) {
          final role = userDoc.data()?['role'];
          if (role != 'employee') {
            _setLoggedIn(false);
            debugPrint('[EmployeeAuthProvider] User role mismatch: $role, logging out');
          }
        });
      } else {
        _setLoggedIn(false);
        _firebaseUser = null;
        _userId = null;
        _userEmail = null;
      }
      notifyListeners();
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

  void _setSuccessMessage(String? message) {
    _successMessage = message;
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

      debugPrint(
        '[EmployeeAuthProvider] Email login successful: ${credential.user?.email}',
      );

      final user = credential.user;
      if (user != null) {
        // Verify role or create profile if missing
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['role'] != 'employee') {
             await _auth.signOut();
             throw FirebaseAuthException(
               code: 'invalid-role', 
               message: 'This account is registered as an ${data['role']}, not an employee.'
             );
          }
        } else {
           // Profile missing - create it (Recovery)
           await _createEmployeeProfile(user);
        }

        // Save session with real Firebase user data
        await SessionService.saveSession(
          role: "employee",
          userId: user.uid,
          email: user.email ?? "",
          authToken: await user.getIdToken() ?? "",
        );
      }

      // Auth state listener will automatically update state
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No employee account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'Employee account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Try again later';
          break;
      }
      _setError(errorMessage);
      debugPrint(
        '[EmployeeAuthProvider] Email login error: ${e.code} - $errorMessage',
      );
    } catch (e) {
      _setError('Login failed: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected email login error: $e');
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
            final idToken = await user.getIdToken();
            await SessionService.saveSession(
              role: "employee",
              userId: user.uid,
              email: user.email ?? "",
              authToken: idToken ?? "",
            );
          }

          debugPrint(
            '[EmployeeAuthProvider] Phone OTP verification successful',
          );
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
          debugPrint(
            '[EmployeeAuthProvider] OTP send error: ${e.code} - $errorMessage',
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
          debugPrint('[EmployeeAuthProvider] OTP sent to $phone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('[EmployeeAuthProvider] OTP auto-retrieval timeout');
        },
      );
    } catch (e) {
      _setError('Failed to send OTP: $e');
      debugPrint('[EmployeeAuthProvider] Unexpected OTP send error: $e');
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

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Save session with Firebase user data
      final user = userCredential.user;
      if (user != null) {
        final idToken = await user.getIdToken();
        await SessionService.saveSession(
          role: "employee",
          userId: user.uid,
          email: user.email ?? "",
          authToken: idToken ?? "",
        );
      }

      debugPrint('[EmployeeAuthProvider] OTP verification successful');

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
      debugPrint(
        '[EmployeeAuthProvider] OTP verification error: ${e.code} - $errorMessage',
      );
    } catch (e) {
      _setError('OTP verification failed: $e');
      debugPrint(
        '[EmployeeAuthProvider] Unexpected OTP verification error: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ======== GOOGLE SIGN-IN ========

  /// Sign in with Google
 Future<void> signInWithGoogle() async {
  _setLoading(true);
  _setError(null);

  try {
    // Use class instance

    // Ensure Google Sign In is signed out first to force account picker
    await _googleSignIn.signOut();
    
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      _setError('Google Sign-In cancelled');
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      // Check if profile exists, if not create it (this handles first-time Google sign-in)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
         final data = userDoc.data();
         if (data != null && data['role'] != 'employee') {
            await _auth.signOut();
            _setError('This account is registered as an ${data['role']}, not an employee.');
            return;
         }
      } else {
        await _createEmployeeProfile(user);
        debugPrint('[EmployeeAuthProvider] Created new employee profile for Google user');
      }

      final idToken = await user.getIdToken();
      await SessionService.saveSession(
        role: "employee",
        userId: user.uid,
        email: user.email ?? "",
        authToken: idToken ?? "",
      );
    }
  } catch (e) {
    _setError("Google Sign-In failed: $e");
  } finally {
    _setLoading(false);
  }
}


  /// Sign up with Google (for registration)
  Future<void> signUpWithGoogle() async {
    await signInWithGoogle(); // Same logic for sign up and sign in
  }

  // ======== FIREBASE EMAIL REGISTRATION ========

  /// Register with Firebase Auth
  Future<void> registerWithFirebaseEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Create user with Firebase Auth
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      debugPrint(
        '[EmployeeAuthProvider] Firebase Auth registration successful: ${credential.user?.email}',
      );

      // Save session with Firebase user data
      final idToken = await credential.user?.getIdToken();
      await SessionService.saveSession(
        role: "employee",
        userId: credential.user?.uid ?? "",
        email: credential.user?.email ?? "",
        authToken: idToken ?? "",
      );

      // Create employee profile in Firestore
      await _createEmployeeProfile(credential.user!);

      // Set success message for UI feedback
      _setSuccessMessage('Registration successful! Welcome to LeoRecruit.');
      
      // Manually update auth state to trigger immediate login
      _firebaseUser = credential.user;
      _userId = credential.user!.uid;
      _userEmail = credential.user!.email;
      _isLoggedIn = true;
      
      notifyListeners();
      debugPrint('[EmployeeAuthProvider] Registration successful - user logged in immediately');

      // Auth state listener will also update state
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
      debugPrint(
        '[EmployeeAuthProvider] Firebase Auth registration error: ${e.code} - $errorMessage',
      );
    } catch (e) {
      _setError('Registration failed: $e');
      debugPrint(
        '[EmployeeAuthProvider] Unexpected Firebase Auth registration error: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Create employee profile in Firestore
  Future<void> _createEmployeeProfile(User user) async {
    try {
      final employeeProfile = {
        'uid': user.uid,
        'email': user.email,
        'role': 'employee',
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'searchTerms': [user.email?.toLowerCase() ?? ''],
      };

      // Create employee profile in employees collection
      await _firestore
          .collection('employees')
          .doc(user.uid)
          .set(employeeProfile);

      // Also create user document for Firebase rules
      final userDoc = {
        'id': user.uid,
        'email': user.email,
        'role': 'employee',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userDoc);

      debugPrint(
        '[EmployeeAuthProvider] Employee profile created in Firestore',
      );

      // Show success message
      _showSuccessMessage('Registration successful! Welcome to Leox');
    } catch (e) {
      debugPrint('[EmployeeAuthProvider] Error creating employee profile: $e');
      // Don't fail registration if profile creation fails
    }
  }

  // Check if profile exists and repair if missing (for already logged-in users)
  Future<void> _checkAndRepairProfile(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _createEmployeeProfile(user);
        debugPrint('[EmployeeAuthProvider] Repaired missing employee profile for ${user.uid}');
      }
    } catch (e) {
      debugPrint('[EmployeeAuthProvider] Profile repair check failed: $e');
    }
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    _setSuccessMessage(message);
    debugPrint('[EmployeeAuthProvider] Success: $message');
  }

  // ======== LOGOUT ========

  /// Logout employee user
  ///
  /// Clears Firebase Auth, session and local state
  Future<void> logout() async {
    try {
      // 1️⃣ Clear session first
      await SessionService.clearAuth();

      // 2️⃣ Sign out from Firebase
      await _googleSignIn.signOut();
      await _auth.signOut();

      // 3️⃣ Force reset everything
      _firebaseUser = null;
      _isLoggedIn = false;
      _userId = null;
      _userEmail = null;
      _verificationId = null;
      _errorMessage = null;

      // 4️⃣ Reset profile provider to prevent cross-contamination
      // Note: This will be called from UI context
      notifyListeners();

      debugPrint('[EmployeeAuthProvider] Logout completed and state reset');
    } catch (e) {
      debugPrint('[EmployeeAuthProvider] Logout error: $e');
    }
  }


  // ======== HELPERS ========

  /// Clear error message (call after showing error to UI)
  void clearError() {
    _setError(null);
  }

  /// Clear success message (call after showing success to UI)
  void clearSuccessMessage() {
    _setSuccessMessage(null);
  }

  /// Check if user has pending phone OTP (waiting for verification code)
  bool get isPendingOtpVerification =>
      _verificationId != null && _verificationId!.isNotEmpty;
}
