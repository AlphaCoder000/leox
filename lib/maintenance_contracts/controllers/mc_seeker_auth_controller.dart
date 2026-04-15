import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mc_seeker_model.dart';

class McSeekerAuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  McSeekerModel? _currentSeeker;
  McSeekerModel? get currentSeeker => _currentSeeker;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    await _auth.signOut();
    _currentSeeker = null;
    notifyListeners();
  }
}
