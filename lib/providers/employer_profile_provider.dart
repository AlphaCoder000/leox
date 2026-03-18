import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/employer_profile_model.dart';
import '../services/profile_service.dart';

class EmployerProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployerProfileModel _profile = EmployerProfileModel(
    name: "",
    email: "",
    phone: "",
    companyName: "",
  );
  EmployerProfileModel get profile => _profile;

  // ======== STATE MANAGEMENT ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ======== METHODS ========

  /// Load employer profile
  Future<void> loadProfile() async {
    _setLoading(true);
    _setError(null);

    try {
      final profile = await _profileService.getEmployerProfile();
      if (profile != null) {
        _profile = profile;
      }
      debugPrint('[EmployerProfileProvider] Profile loaded: ${_profile.name}');
    } catch (e) {
      _setError('Failed to load profile: $e');
      debugPrint('[EmployerProfileProvider] Error loading profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update employer profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String companyName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final updateData = {
        'name': name,
        'phone': phone,
        'companyName': companyName,
      };

      await _profileService.updateEmployerProfile(updateData);
      
      // Reload or update local
      _profile.name = name;
      _profile.phone = phone;
      _profile.companyName = companyName;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload profile picture to profile-images folder
  Future<bool> uploadProfilePicture(XFile file) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload to profile-images/{userId}.jpg (same folder as employees)
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile-images/${user.uid}.jpg');
      
      final uploadTask = await ref.putFile(File(file.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      // Update employer profile with new picture URL
      await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .update({
            'profilePicture': downloadUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Reload profile to get updated data
      await loadProfile();
      
      debugPrint('[EmployerProfileProvider] Profile picture uploaded and state updated');
      return true;
    } catch (e) {
      _setError('Failed to upload picture: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String uid = user.uid;

      // Delete profile picture
      if ((_profile.profilePicture ?? "").isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .ref()
              .child('profile-images/$uid.jpg')
              .delete();
        } catch (_) {}
      }

      // Delete jobs posted by employer
      final firestore = FirebaseFirestore.instance;
      final jobsQuery = await firestore.collection('jobs').where('employerId', isEqualTo: uid).get();
      for (var doc in jobsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete employer document
      await firestore.collection('employers').doc(uid).delete();
      await firestore.collection('users').doc(uid).delete();

      // Finally delete user from Firebase Auth
      await user.delete();

      _profile = EmployerProfileModel(
        name: "",
        email: "",
        phone: "",
        companyName: "",
      );
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _setError('Please log out and log back in to permanently delete your account.');
      } else {
        _setError(e.message ?? 'Authentication failed');
      }
      return false;
    } catch (e) {
      _setError('Failed to delete account. $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
}
