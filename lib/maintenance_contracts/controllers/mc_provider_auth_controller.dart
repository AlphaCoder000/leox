import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mc_provider_model.dart';

class McProviderAuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  McProviderModel? _currentProvider;
  McProviderModel? get currentProvider => _currentProvider;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    await _auth.signOut();
    _currentProvider = null;
    notifyListeners();
  }
}
