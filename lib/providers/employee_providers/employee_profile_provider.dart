import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/employee_profile_model.dart';
import '../../services/profile_service.dart';
import '../../services/storage_service.dart';

class EmployeeProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  
  // ======== STATE ========
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EmployeeProfileModel? _profile;
  EmployeeProfileModel? get profile => _profile;

  int _profileCompletion = 0;
  int get profileCompletion => _profileCompletion;

  List<String> _completionSuggestions = [];
  List<String> get completionSuggestions => _completionSuggestions;

  // ======== METHODS ========
  
  /// Reset provider state (call on logout)
  void reset() {
    _profile = null;
    _errorMessage = null;
    _isLoading = false;
    _profileCompletion = 0;
    _completionSuggestions = [];
    debugPrint('[EmployeeProfileProvider] Provider reset');
  }

  // ======== PRIVATE METHODS ========
  void _setLoading(bool value) {
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String? error) {
    _errorMessage = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // ======== PUBLIC METHODS ========

  /// Load profile from Firebase
  Future<void> loadProfile() async {
    // Check if user is authenticated before proceeding
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[EmployeeProfileProvider] User not authenticated, skipping profile load');
      return;
    }

    debugPrint('[EmployeeProfileProvider] Loading profile for user: ${user.uid}');
    _setLoading(true);
    _setError(null);

    try {
      // Use ProfileService to get profile
      final profile = await _profileService.getEmployeeProfile();
      if (profile != null) {
        _profile = profile;
        debugPrint('[EmployeeProfileProvider] Profile loaded: ${profile.firstName} ${profile.lastName}');
      } else {
        throw Exception('Employee profile not found');
      }
    } catch (e) {
      debugPrint('[EmployeeProfileProvider] Error loading profile: $e');
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile in Firebase
  Future<void> updateProfile(EmployeeProfileModel updatedProfile) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Update profile in Firebase
      await _firestore.collection('employees').doc(user.uid).update({
        'firstName': updatedProfile.firstName,
        'lastName': updatedProfile.lastName,
        'headline': updatedProfile.headline,
        'bio': updatedProfile.bio,
        'phone': updatedProfile.phone,
        'skills': updatedProfile.skills,
        'resumeUrl': updatedProfile.resumeUrl,
        'updatedAt': Timestamp.now(),
      });

      // Update local profile
      _profile = updatedProfile;
      _profileCompletion = _calculateProfileCompletion(updatedProfile);
      _generateCompletionSuggestions();

      debugPrint('[EmployeeProfileProvider] Profile updated successfully');
    } catch (e) {
      debugPrint('[EmployeeProfileProvider] Error updating profile: $e');
      _setError('Failed to update profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Upload profile picture to profile-images folder
  Future<bool> uploadProfilePicture(dynamic file) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('[EmployeeProfileProvider] Uploading profile picture for user: ${user.uid}');

      XFile? imageFile;
      if (file is XFile) {
        imageFile = file;
      } else if (file is PlatformFile && file.path != null) {
        imageFile = XFile(file.path!);
      } else {
        throw Exception('Invalid file type');
      }

      // Use ProfileService to upload
      final downloadUrl = await _profileService.updateEmployeeProfilePicture(imageFile);
      
      if (downloadUrl != null) {
        debugPrint('[EmployeeProfileProvider] Profile picture uploaded successfully');
        
        // Update local profile directly to avoid setState during build
        if (_profile != null) {
          _profile = _profile!.copyWith(profilePicture: downloadUrl);
          notifyListeners();
        }
        
        return true;
      }
      
      throw Exception('Failed to upload profile picture');
    } catch (e) {
      debugPrint('[EmployeeProfileProvider] Error uploading profile picture: $e');
      _setError('Failed to upload profile picture: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload resume to resumes folder
  Future<bool> uploadResume(dynamic file) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('[EmployeeProfileProvider] Uploading resume for user: ${user.uid}');

      XFile? resumeFile;
      if (file is PlatformFile && file.path != null) {
        resumeFile = XFile(file.path!);
      } else if (file is XFile) {
        resumeFile = file;
      } else {
        throw Exception('Invalid file type');
      }

      // Use ProfileService to upload
      final downloadUrl = await _profileService.updateEmployeeResume(resumeFile);
      
      if (downloadUrl != null) {
        debugPrint('[EmployeeProfileProvider] Resume uploaded successfully');
        
        // Update local profile directly to avoid setState during build
        if (_profile != null) {
          _profile = _profile!.copyWith(resumeUrl: downloadUrl);
          notifyListeners();
        }
        
        return true;
      }
      
      throw Exception('Failed to upload resume');
    } catch (e) {
      debugPrint('[EmployeeProfileProvider] Error uploading resume: $e');
      _setError('Failed to upload resume: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete resume from Firebase Storage and Firestore
  Future<bool> deleteResume() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('[EmployeeProfileProvider] Deleting resume for user: ${user.uid}');

      // Get current profile to get resume URL
      final currentProfile = await _profileService.getEmployeeProfile();
      if (currentProfile?.resumeUrl != null && currentProfile!.resumeUrl.isNotEmpty) {
        // Delete file from Firebase Storage
        await _storageService.deleteFile(currentProfile.resumeUrl);
        debugPrint('[EmployeeProfileProvider] Resume file deleted from storage');
      }

      // Update profile to remove resume URL
      await _profileService.updateEmployeeProfile({
        'resumeUrl': null,
        'resumeName': null,
      });

      debugPrint('[EmployeeProfileProvider] Resume deleted successfully');
      
      // Update local profile directly to avoid setState during build
      if (_profile != null) {
        _profile = _profile!.copyWith(resumeUrl: '');
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      debugPrint('[EmployeeProfileProvider] Error deleting resume: $e');
      _setError('Failed to delete resume: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate profile completion percentage
  int _calculateProfileCompletion(EmployeeProfileModel profile) {
    int completedFields = 0;
    int totalFields = 6; // firstName, lastName, headline, bio, skills, resume

    if (profile.firstName.isNotEmpty) completedFields++;
    if (profile.lastName.isNotEmpty) completedFields++;
    if (profile.headline.isNotEmpty) completedFields++;
    if (profile.bio.isNotEmpty) completedFields++;
    if (profile.skills.isNotEmpty) completedFields++;
    if (profile.resumeUrl.isNotEmpty) completedFields++;

    return (completedFields / totalFields * 100).round();
  }

  /// Generate completion suggestions
  void _generateCompletionSuggestions() {
    _completionSuggestions = [];
    
    if (_profile != null) {
      if (_profile!.firstName.isEmpty) {
        _completionSuggestions.add('Add your first name');
      }
      if (_profile!.lastName.isEmpty) {
        _completionSuggestions.add('Add your last name');
      }
      if (_profile!.headline.isEmpty) {
        _completionSuggestions.add('Add a professional headline');
      }
      if (_profile!.bio.isEmpty) {
        _completionSuggestions.add('Write a compelling bio');
      }
      if (_profile!.skills.isEmpty) {
        _completionSuggestions.add('Add your key skills');
      }
      if (_profile!.resumeUrl.isEmpty) {
        _completionSuggestions.add('Upload your resume');
      }
    }
  }

  Future<void> addSkill(String skill) async {
    if (_profile == null) return;

    if (!_profile!.skills.contains(skill)) {
      _profile!.skills.add(skill);
      _profileCompletion = _calculateProfileCompletion(_profile!);
      _generateCompletionSuggestions();
      notifyListeners();

      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('employees').doc(user.uid).update({
            'skills': _profile!.skills,
          });
          debugPrint('[EmployeeProfileProvider] Permanently added skill: $skill to Firestore');
        }
      } catch (e) {
        debugPrint('[EmployeeProfileProvider] Error adding skill to Firestore: $e');
      }
    }
  }

  Future<void> removeSkill(String skill) async {
    if (_profile == null) return;

    if (_profile!.skills.contains(skill)) {
      _profile!.skills.remove(skill);
      _profileCompletion = _calculateProfileCompletion(_profile!);
      _generateCompletionSuggestions();
      notifyListeners();

      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('employees').doc(user.uid).update({
            'skills': _profile!.skills,
          });
          debugPrint('[EmployeeProfileProvider] Permanently removed skill: $skill from Firestore');
        }
      } catch (e) {
        debugPrint('[EmployeeProfileProvider] Error removing skill from Firestore: $e');
      }
    }
  }

  /// Delete Employee Account entirely
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String uid = user.uid;

      // Delete Profile picture
      if (_profile?.profilePicture != null && _profile!.profilePicture.isNotEmpty) {
        try {
          await _storageService.deleteFile(_profile!.profilePicture);
        } catch (_) {}
      }
      
      // Delete Resume
      if (_profile?.resumeUrl != null && _profile!.resumeUrl.isNotEmpty) {
        try {
          await _storageService.deleteFile(_profile!.resumeUrl);
        } catch (_) {}
      }

      // Delete applications applied by employee
      final applicationsQuery = await _firestore.collection('applications').where('employeeId', isEqualTo: uid).get();
      for (var doc in applicationsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete employee document
      await _firestore.collection('employees').doc(uid).delete();
      await _firestore.collection('users').doc(uid).delete();

      // Finally delete user
      await user.delete();

      reset();
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        try {
          final user = _auth.currentUser;
          if (user != null) {
            bool isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
            if (isGoogle) {
              final googleSignIn = GoogleSignIn();
              final googleUser = await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
              if (googleUser != null) {
                final googleAuth = await googleUser.authentication;
                final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
                await user.reauthenticateWithCredential(credential);
                await user.delete(); // Delete after re-auth
                
                reset();
                return true;
              }
            }
          }
        } catch (_) {}
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
    }
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }
}
