import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/employee_profile_model.dart';
import '../../services/employee_profile_api_service.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class EmployeeProfileProvider extends ChangeNotifier {
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

  final bool _isPublic = true;
  bool get isPublic => _isPublic;

  // ======== PRIVATE METHODS ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ======== PUBLIC METHODS ========

  /// Load profile from API
  ///
  /// Fetches complete profile data from backend
  ///
  /// Logs: Fetch attempt and success
  Future<void> loadProfile() async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token from session
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated. Please login first.');
      }

      // LOG: Fetch initiation
      debugPrint('[EmployeeProfileProvider] Loading profile...');

      // Call API
      final profile = await EmployeeProfileApiService.getProfile(
        authToken: authToken,
      );

      _profile = profile;
      _profileCompletion = profile.completionPercentage;

      // LOG: Success
      debugPrint('[EmployeeProfileProvider] Profile loaded:');
      debugPrint('  - Name: ${profile.fullName}');
      debugPrint('  - Email: ${profile.email}');
      debugPrint('  - Completion: ${profile.completionPercentage}%');
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] API Error: ${e.message}');
    } catch (e) {
      _setError('Failed to load profile: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile with new data
  ///
  /// [firstName] - Optional
  /// [lastName] - Optional
  /// [phone] - Optional
  /// [bio] - Optional
  /// [headline] - Optional job title
  /// [skills] - Optional list of skills
  /// [experienceYears] - Optional years of experience
  ///
  /// Logs: Update attempt and success
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? headline,
    List<String>? skills,
    double? experienceYears,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Update attempt
      debugPrint('[EmployeeProfileProvider] Updating profile...');

      // Call API
      final updatedProfile = await EmployeeProfileApiService.updateProfile(
        authToken: authToken,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
        headline: headline,
        skills: skills,
        experienceYears: experienceYears,
      );

      // Update state
      _profile = updatedProfile;
      _profileCompletion = updatedProfile.completionPercentage;

      // LOG: Success
      debugPrint('[EmployeeProfileProvider] Profile updated successfully');

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Update error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to update profile: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update only bio field
  ///
  /// Convenience method for quick bio updates
  Future<bool> updateBio(String bio) async {
    return await updateProfile(bio: bio);
  }

  /// Update only headline (job title)
  ///
  /// Convenience method for quick updates
  Future<bool> updateHeadline(String headline) async {
    return await updateProfile(headline: headline);
  }

  /// Add a skill to profile
  ///
  /// [skill] - Skill name to add
  ///
  /// Logs: Add attempt and success
  Future<bool> addSkill(String skill) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Add attempt
      debugPrint('[EmployeeProfileProvider] Adding skill: $skill');

      // Call API
      final updated = await EmployeeProfileApiService.addSkill(
        authToken: authToken,
        skill: skill,
      );

      _profile = updated;
      _profileCompletion = updated.completionPercentage;

      // LOG: Success
      debugPrint('[EmployeeProfileProvider] Skill added: $skill');

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Add skill error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to add skill: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove a skill from profile
  ///
  /// [skill] - Skill name to remove
  ///
  /// Logs: Remove attempt and success
  Future<bool> removeSkill(String skill) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Remove attempt
      debugPrint('[EmployeeProfileProvider] Removing skill: $skill');

      // Call API
      final updated = await EmployeeProfileApiService.removeSkill(
        authToken: authToken,
        skill: skill,
      );

      _profile = updated;
      _profileCompletion = updated.completionPercentage;

      // LOG: Success
      debugPrint('[EmployeeProfileProvider] Skill removed: $skill');

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Remove skill error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to remove skill: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load profile completion suggestions
  ///
  /// Logs: Fetch attempt and count
  Future<void> loadCompletionSuggestions() async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) return;

      // LOG: Fetch initiation
      debugPrint('[EmployeeProfileProvider] Loading completion suggestions...');

      // Call API
      final response = await EmployeeProfileApiService.getCompletionSuggestions(
        authToken: authToken,
      );

      _profileCompletion =
          _parseInt(response['percentage']) ?? _profileCompletion;
      _completionSuggestions = _parseStringList(response['suggestions']);

      // LOG: Success
      debugPrint(
        '[EmployeeProfileProvider] Loaded ${_completionSuggestions.length} suggestions',
      );

      notifyListeners();
    } on ApiException catch (e) {
      debugPrint('[EmployeeProfileProvider] Suggestions error: ${e.message}');
    } catch (e) {
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Upload profile picture
  ///
  /// NOTE: Currently a placeholder until file upload is implemented
  Future<bool> uploadProfilePicture(String filePath) async {
    _setLoading(true);
    _setError(null);

    try {
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Upload attempt
      debugPrint('[EmployeeProfileProvider] Uploading profile picture...');

      // Call API (currently throws "not implemented")
      await EmployeeProfileApiService.uploadProfilePicture(
        authToken: authToken,
        fileName: filePath.split('/').last,
        filePath: filePath,
      );

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Upload error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to upload picture: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete profile picture
  ///
  /// Logs: Delete attempt and success
  Future<bool> deleteProfilePicture() async {
    _setLoading(true);
    _setError(null);

    try {
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Delete attempt
      debugPrint('[EmployeeProfileProvider] Deleting profile picture...');

      // Call API
      await EmployeeProfileApiService.deleteProfilePicture(
        authToken: authToken,
      );

      // Update local profile
      if (_profile != null) {
        _profile = _profile!.copyWith(profilePicture: null);
      }

      // LOG: Success
      debugPrint('[EmployeeProfileProvider] Profile picture deleted');

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Delete error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to delete picture: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload resume
  ///
  /// NOTE: Currently a placeholder until file upload is implemented
  Future<bool> uploadResume(String filePath) async {
    _setLoading(true);
    _setError(null);

    try {
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Upload attempt
      debugPrint('[EmployeeProfileProvider] Uploading resume...');

      // Call API (currently throws "not implemented")
      await EmployeeProfileApiService.uploadResume(
        authToken: authToken,
        fileName: filePath.split('/').last,
        filePath: filePath,
      );

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Resume upload error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to upload resume: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete resume
  ///
  /// Logs: Delete attempt and success
  Future<bool> deleteResume() async {
    _setLoading(true);
    _setError(null);

    try {
      final authToken = await SessionService.getAuthToken();
      if (authToken == null) {
        throw ApiException(message: 'Not authenticated.');
      }

      // LOG: Delete attempt
      debugPrint('[EmployeeProfileProvider] Deleting resume...');

      // Call API
      await EmployeeProfileApiService.deleteResume(authToken: authToken);

      // Update local profile
      if (_profile != null) {
        _profile = _profile!.copyWith(resumeUrl: null);
      }

      // LOG: Success
      debugPrint('[EmployeeProfileProvider] Resume deleted');

      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      debugPrint('[EmployeeProfileProvider] Delete error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to delete resume: $e');
      debugPrint('[EmployeeProfileProvider] Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  // ======== BACKWARD COMPATIBILITY ========

  /// Get profile name (for backward compatibility)
  String get name => _profile?.fullName ?? 'User';

  /// Get profile email
  String get email => _profile?.email ?? '';

  /// Get profile phone
  String get phone => _profile?.phone ?? '';

  /// Get profile skills
  List<String> get skills => _profile?.skills ?? [];

  /// Get location (placeholder - can be added to bio)
  String get location => _profile?.bio ?? '';

  /// Get resume path/URL
  String get resumePath => _profile?.resumeUrl ?? '';

  /// Check if profile is complete (80%+ filled)
  bool get isComplete => _profileCompletion >= 80;

  /// Check if profile needs work (< 50%)
  bool get needsCompletion => _profileCompletion < 50;

  // ======== HELPER FUNCTIONS ========

  /// Parse integer value safely
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse list of strings safely
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }
}
