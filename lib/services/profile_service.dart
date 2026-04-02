import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leox/services/storage_service.dart';
import '../models/employee_profile_model.dart';
import '../models/employer_profile_model.dart';

/// Profile Service - User Profile Management
///
/// Handles profile operations for both employers and employees.
/// Provides CRUD operations for user profiles.
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  // ======== EMPLOYEE PROFILE ========

  Future<EmployeeProfileModel?> getEmployeeProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc =
          await _firestore.collection('employees').doc(user.uid).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return EmployeeProfileModel.fromJson(data);
    } catch (e) {
      debugPrint('[ProfileService] Error getting employee profile: $e');
      return null;
    }
  }

  Future<void> saveEmployeeProfile(EmployeeProfileModel profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('employees').doc(user.uid).set({
        ...profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[ProfileService] Employee profile saved');
    } catch (e) {
      debugPrint('[ProfileService] Error saving employee profile: $e');
      rethrow;
    }
  }

  Future<void> updateEmployeeProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('employees').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[ProfileService] Employee profile updated');
    } catch (e) {
      debugPrint('[ProfileService] Error updating employee profile: $e');
      rethrow;
    }
  }

  Future<String?> updateEmployeeProfilePicture(XFile file) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final downloadUrl = await _storageService.uploadFile(
        file,
        'profile-images/$userId.jpg',
      );

      if (downloadUrl != null) {
        await updateEmployeeProfile({'profilePicture': downloadUrl});
        return downloadUrl;
      }
      return null;
    } catch (e) {
      debugPrint(
          '[ProfileService] Error updating employee profile picture: $e');
      rethrow;
    }
  }

  Future<String?> updateEmployeeResume(XFile file) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = file.name;
      final fileExtension = fileName.split('.').last;
      
      final downloadUrl = await _storageService.uploadFile(
        file,
        'resumes/${userId}_resume.$fileExtension',
      );

      if (downloadUrl != null) {
        await updateEmployeeProfile({
          'resumeUrl': downloadUrl,
          'resumeName': fileName,
        });
        return downloadUrl;
      }
      return null;
    } catch (e) {
      debugPrint('[ProfileService] Error updating employee resume: $e');
      rethrow;
    }
  }

  // ======== EMPLOYER PROFILE ========

  Future<EmployerProfileModel?> getEmployerProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc =
          await _firestore.collection('employers').doc(user.uid).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return EmployerProfileModel.fromJson(data);
    } catch (e) {
      debugPrint('[ProfileService] Error getting employer profile: $e');
      return null;
    }
  }

  Future<void> saveEmployerProfile(EmployerProfileModel profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('employers').doc(user.uid).set({
        ...profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[ProfileService] Employer profile saved with merge');
    } catch (e) {
      debugPrint('[ProfileService] Error saving employer profile: $e');
      rethrow;
    }
  }

  Future<void> updateEmployerProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('employers').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[ProfileService] Employer profile updated');
    } catch (e) {
      debugPrint('[ProfileService] Error updating employer profile: $e');
      rethrow;
    }
  }

  Future<String?> updateEmployerProfilePicture(XFile file) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final downloadUrl = await _storageService.uploadFile(
        file,
        'profile-images/$userId.jpg',
      );

      if (downloadUrl != null) {
        await updateEmployerProfile({'profilePicture': downloadUrl});
        return downloadUrl;
      }
      return null;
    } catch (e) {
      debugPrint(
          '[ProfileService] Error updating employer profile picture: $e');
      rethrow;
    }
  }

  // ======== PROFILE COMPLETENESS ========

  Future<bool> isEmployeeProfileComplete() async {
    final profile = await getEmployeeProfile();
    if (profile == null) return false;
    return profile.isComplete;
  }

  Future<bool> isEmployerProfileComplete() async {
    final profile = await getEmployerProfile();
    if (profile == null) return false;

    return profile.name.isNotEmpty &&
        profile.companyName.isNotEmpty &&
        profile.email.isNotEmpty;
  }
}
