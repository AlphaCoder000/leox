import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leox/services/session_service.dart';
import '../models/mc_provider_model.dart';

class McProviderAuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '340682426505-q2q1h7ooeua23piinorknvbcu0scma06.apps.googleusercontent.com',
    clientId: '340682426505-a78q5kk98ird4kh2emig2327aonakmbl.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  McProviderModel? _currentProvider;
  McProviderModel? get currentProvider => _currentProvider;
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
        final doc = await _firestore.collection('mc_providers').doc(user.uid).get();
        if (doc.exists) {
          _currentProvider = McProviderModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        } else {
          final newProvider = McProviderModel(
            id: user.uid,
            companyName: user.displayName ?? 'New Company',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            location: '',
            rating: 0.0,
            profilePicture: user.photoURL ?? '',
          );
          await _firestore.collection('mc_providers').doc(newProvider.id).set(newProvider.toJson());
          _currentProvider = newProvider;
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

  Future<void> fetchProviderProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('mc_providers').doc(uid).get();
      if (doc.exists) {
        _currentProvider = McProviderModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching provider profile: $e");
    }
  }

  Future<String?> registerWithEmail(String email, String password, String companyName, String phone, String location) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      McProviderModel newProvider = McProviderModel(
        id: userCredential.user!.uid,
        companyName: companyName,
        email: email,
        phone: phone,
        location: location,
        rating: 0.0,
        profilePicture: '',
      );

      await _firestore.collection('mc_providers').doc(newProvider.id).set(newProvider.toJson());
      _currentProvider = newProvider;
      
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
      await fetchProviderProfile(userCredential.user!.uid);
      
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
    _currentProvider = null;
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
      final providerId = user.uid;

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
            .child('maintenance_contracts/profiles/$providerId')
            .delete();
      } catch (e) {
        // Ignore if file doesn't exist or deletion fails
        debugPrint("Error deleting provider profile picture from storage: $e");
      }

      // 3. Delete related data in Firestore
      // 3a. Delete services offered by this provider
      final servicesSnapshot = await _firestore
          .collection('mc_services')
          .where('providerId', isEqualTo: providerId)
          .get();
      for (var doc in servicesSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3b. Delete incoming requests for this provider
      final requestsSnapshot = await _firestore
          .collection('mc_requests')
          .where('providerId', isEqualTo: providerId)
          .get();
      for (var doc in requestsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3c. Delete reviews for this provider
      final reviewsSnapshot = await _firestore
          .collection('mc_reviews')
          .where('providerId', isEqualTo: providerId)
          .get();
      for (var doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3d. Delete the provider's profile document
      await _firestore.collection('mc_providers').doc(providerId).delete();

      // 4. Delete user from Firebase Auth
      await user.delete();

      _currentProvider = null;
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
