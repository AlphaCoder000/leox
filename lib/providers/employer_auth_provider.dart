import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leox/services/session_service.dart';

class EmployerAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '340682426505-q2q1h7ooeua23piinorknvbcu0scma06.apps.googleusercontent.com',
    clientId: '340682426505-a78q5kk98ird4kh2emig2327aonakmbl.apps.googleusercontent.com', // Added Android-specific client ID
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

  EmployerAuthProvider() {
    _initializeAuthState();
  }

  /// Initialize Firebase Auth state listener
void _initializeAuthState() {
  _auth.authStateChanges().listen((User? user) async {
    debugPrint('[EmployerAuthProvider] Auth state changed: ${user?.uid}');
    _firebaseUser = user;

    if (user != null) {
      // Quick login without Firestore check for better performance
      _setLoggedIn(true);
      _userId = user.uid;
      _userEmail = user.email;
      
      // Background role check (non-blocking) - verifies if user is an employer
      // Using retry logic to handle potential race condition during registration
      _checkRoleWithRetry(user.uid);
    } else {
      _setLoggedIn(false);
      _userId = null;
      _userEmail = null;
    }
    notifyListeners();
  });
}

Future<void> _checkRoleWithRetry(String uid) async {
  for (int i = 0; i < 3; i++) {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'];
        if (role != 'employer') {
          _setLoggedIn(false);
          debugPrint('[EmployerAuthProvider] User role is $role (not employer). Internal state updated.');
        } else {
          _setLoggedIn(true); // Re-confirm
          debugPrint('[EmployerAuthProvider] User role confirmed: employer.');
        }
        return; // Success
      }
      
      debugPrint('[EmployerAuthProvider] User document not found, retry ${i + 1}/3...');
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('[EmployerAuthProvider] Error checking role: $e');
    }
  }
  
  // After all retries
  _setLoggedIn(false);
  debugPrint('[EmployerAuthProvider] User document not found after retries. Internal state updated.');
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

  // ======== PUBLIC METHODS ========

  /// Login with Google Sign-In
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      // Ensure Google Sign In is signed out first to force account picker
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Verify role or create profile if missing
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['role'] != 'employer') {
            await _auth.signOut();
            _setError('This account is registered as an ${data['role']}, not an employer.');
            return;
          }
        } else {
          // New Google account - default to employer if signed in from this view
          await _createEmployerProfile(user);
          debugPrint('[EmployerAuthProvider] Created new employer profile for Google user');
        }

        final idToken = await user.getIdToken();
        await SessionService.saveSession(
          role: "employer",
          userId: user.uid,
          email: user.email ?? "",
          authToken: idToken ?? "",
        );

        // Manually update state for immediate UI reaction
        _firebaseUser = user;
        _userId = user.uid;
        _userEmail = user.email;
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      _setError("Google Sign-In failed: $e");
      debugPrint('[EmployerAuthProvider] Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with Google (for registration)
  Future<void> signUpWithGoogle() async {
    await signInWithGoogle();
  }

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
        '[EmployerAuthProvider] Firebase Auth registration successful: ${credential.user?.email}',
      );

      // Save session with Firebase user data
      final idToken = await credential.user?.getIdToken();
      await SessionService.saveSession(
        role: "employer",
        userId: credential.user?.uid ?? "",
        email: credential.user?.email ?? "",
        authToken: idToken ?? "",
      );

      // Create employer profile in Firestore
      await _createEmployerProfile(credential.user!);

      // Set success message for UI feedback
      _setSuccessMessage('Registration successful! Welcome to LeoRecruit.');
      
      // Manually update auth state to trigger immediate login
      _firebaseUser = credential.user;
      _userId = credential.user!.uid;
      _userEmail = credential.user!.email;
      _isLoggedIn = true;
      
      notifyListeners();
      debugPrint('[EmployerAuthProvider] Registration successful - user logged in immediately');

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
        '[EmployerAuthProvider] Firebase Auth registration error: ${e.code} - $errorMessage',
      );
    } catch (e) {
      _setError('Registration failed: $e');
      debugPrint(
        '[EmployerAuthProvider] Unexpected Firebase Auth registration error: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Login with Firebase Auth
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint(
        '[EmployerAuthProvider] Email login successful: ${credential.user?.email}',
      );

      final user = credential.user;
      if (user != null) {
        // Verify role or create profile if missing
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['role'] != 'employer') {
             await _auth.signOut();
             throw FirebaseAuthException(
               code: 'invalid-role', 
               message: 'This account is registered as an ${data['role']}, not an employer.'
             );
          }
        } else {
           // Profile missing - create it (Recovery)
           await _createEmployerProfile(user);
        }

        // Save session with real Firebase user data
        await SessionService.saveSession(
          role: "employer",
          userId: user.uid,
          email: user.email ?? "",
          authToken: await user.getIdToken() ?? "",
        );

        // Manually update internal state for immediate navigation
        _firebaseUser = user;
        _userId = user.uid;
        _userEmail = user.email;
        _isLoggedIn = true;
        notifyListeners();
      }

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
      debugPrint(
        '[EmployerAuthProvider] Email login error: ${e.code} - $errorMessage',
      );
    } catch (e) {
      _setError('Login failed: $e');
      debugPrint('[EmployerAuthProvider] Unexpected email login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create employer profile in Firestore
  Future<void> _createEmployerProfile(User user) async {
    try {
      // 1. Create user document for role check (First! to avoid race condition)
      final userDoc = {
        'id': user.uid,
        'email': user.email,
        'role': 'employer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userDoc);

      // 2. Create or update detailed employer profile
      final employerProfile = {
        'uid': user.uid,
        'email': user.email,
        'role': 'employer',
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'searchTerms': [user.email?.toLowerCase() ?? ''],
      };

      await _firestore
          .collection('employers')
          .doc(user.uid)
          .set(employerProfile, SetOptions(merge: true));

      debugPrint(
        '[EmployerAuthProvider] Employer profile created in Firestore',
      );
    } catch (e) {
      debugPrint(
        '[EmployerAuthProvider] Error creating employer profile: $e',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      
      // 1. Clear session
      await SessionService.clearAuth();

      // 2. Safe Sign out from Google and Firebase
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } catch (e) {
        debugPrint('[EmployerAuthProvider] Google Sign-Out error: $e');
      }

      await _auth.signOut();
      debugPrint('[EmployerAuthProvider] Logout initiated via FirebaseAuth.signOut()');

      // Note: State reset and notifyListeners() are handled by the authStateChanges() listener
    } catch (e) {
      debugPrint('[EmployerAuthProvider] Logout error: $e');
    } finally {
      _setLoading(false);
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

  /// Public wrapper so UI/tests can set loading state
  void setLoading(bool value) {
    _setLoading(value);
  }


}
