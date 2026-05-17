import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leox/services/session_service.dart';
import '../models/mc_seeker_model.dart';

class McSeekerAuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '340682426505-q2q1h7ooeua23piinorknvbcu0scma06.apps.googleusercontent.com',
    clientId: '340682426505-a78q5kk98ird4kh2emig2327aonakmbl.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  McSeekerModel? _currentSeeker;
  McSeekerModel? get currentSeeker => _currentSeeker;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint("Error signing out from Google Sign-In: $e");
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return "Sign-In cancelled by user";
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final doc = await _firestore.collection('mc_seekers').doc(user.uid).get();
        if (doc.exists) {
          _currentSeeker = McSeekerModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        } else {
          final newSeeker = McSeekerModel(
            id: user.uid,
            userName: user.displayName ?? 'New Seeker',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            address: '',
            profilePicture: user.photoURL ?? '',
          );
          await _firestore.collection('mc_seekers').doc(newSeeker.id).set(newSeeker.toJson());
          _currentSeeker = newSeeker;
        }
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> signUpWithGoogle() async {
    return signInWithGoogle();
  }

  Future<void> fetchSeekerProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('mc_seekers').doc(uid).get();
      if (doc.exists) {
        _currentSeeker = McSeekerModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching seeker profile: $e");
    }
  }

  Future<String?> registerWithEmail(String email, String password, String userName, String phone, String address) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      McSeekerModel newSeeker = McSeekerModel(
        id: userCredential.user!.uid,
        userName: userName,
        email: email,
        phone: phone,
        address: address,
      );

      await _firestore.collection('mc_seekers').doc(newSeeker.id).set(newSeeker.toJson());
      _currentSeeker = newSeeker;
      
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchSeekerProfile(userCredential.user!.uid);
      
      // Fetch reviews after successful login
      // Reviews will be fetched by the dashboard controller when needed
      
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await SessionService.clearAuth();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint("Error signing out from Google: $e");
    }
    await _auth.signOut();
    _currentSeeker = null;
    notifyListeners();
  }

  Future<String?> deleteAccount(String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return "No user logged in";
      }
      final seekerId = user.uid;

      // 1. Re-authenticate user first
      if (user.email != null) {
        try {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          _isLoading = false;
          notifyListeners();
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            return "Incorrect password. Please try again.";
          }
          return e.message ?? "Authentication failed. Please check your password.";
        }
      }

      // 2. Delete from Firebase Storage (Profile Picture)
      try {
        await FirebaseStorage.instance
            .ref()
            .child('maintenance_contracts/profiles/$seekerId')
            .delete();
      } catch (e) {
        // Ignore if file doesn't exist or deletion fails
        debugPrint("Error deleting seeker profile picture from storage: $e");
      }

      // 3. Delete related data in Firestore
      // 3a. Delete requests booked by this seeker
      final requestsSnapshot = await _firestore
          .collection('mc_requests')
          .where('seekerId', isEqualTo: seekerId)
          .get();
      for (var doc in requestsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3b. Delete reviews written by this seeker
      final reviewsSnapshot = await _firestore
          .collection('mc_reviews')
          .where('seekerId', isEqualTo: seekerId)
          .get();
      for (var doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3c. Delete the seeker's profile document
      await _firestore.collection('mc_seekers').doc(seekerId).delete();

      // 4. Delete user from Firebase Auth
      await user.delete();

      _currentSeeker = null;
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
}
