import 'api_service.dart';
import '../models/employee_profile_model.dart';

/// Employee Profile API Service
///
/// Handles all profile-related API calls for employees:
/// - Fetch and update profile
/// - Upload profile picture and resume
/// - Manage profile visibility and settings
class EmployeeProfileApiService {
  /// Fetch the current employee's profile
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: EmployeeProfileModel with complete profile data
  static Future<EmployeeProfileModel> getProfile({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/profile',
        authToken: authToken,
      );

      return EmployeeProfileModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update employee profile fields
  ///
  /// Allows updating any profile field. Omitted fields are not changed.
  ///
  /// [authToken] - Auth token (required)
  /// [firstName] - Optional first name
  /// [lastName] - Optional last name
  /// [phone] - Optional phone number
  /// [bio] - Optional bio/about text
  /// [headline] - Optional job title or headline
  /// [skills] - Optional list of skills
  /// [experienceYears] - Optional years of experience
  ///
  /// Returns: Updated EmployeeProfileModel
  static Future<EmployeeProfileModel> updateProfile({
    required String authToken,
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? headline,
    List<String>? skills,
    double? experienceYears,
  }) async {
    try {
      // Build request body with only provided fields
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (bio != null) body['bio'] = bio;
      if (headline != null) body['headline'] = headline;
      if (skills != null && skills.isNotEmpty) body['skills'] = skills;
      if (experienceYears != null) body['experienceYears'] = experienceYears;

      final response = await ApiService.put(
        '/employee/profile',
        body: body,
        authToken: authToken,
      );

      return EmployeeProfileModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update only bio field
  ///
  /// Convenience method for common update
  static Future<EmployeeProfileModel> updateBio({
    required String authToken,
    required String bio,
  }) async {
    try {
      return await updateProfile(authToken: authToken, bio: bio);
    } catch (e) {
      rethrow;
    }
  }

  /// Update only headline (job title)
  ///
  /// Convenience method for common update
  static Future<EmployeeProfileModel> updateHeadline({
    required String authToken,
    required String headline,
  }) async {
    try {
      return await updateProfile(authToken: authToken, headline: headline);
    } catch (e) {
      rethrow;
    }
  }

  /// Update skills list
  ///
  /// Convenience method for common update
  static Future<EmployeeProfileModel> updateSkills({
    required String authToken,
    required List<String> skills,
  }) async {
    try {
      return await updateProfile(authToken: authToken, skills: skills);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile picture
  ///
  /// [authToken] - Auth token (required)
  /// [fileName] - Name of the file (e.g., "avatar.jpg")
  /// [filePath] - Local file path to image
  ///
  /// NOTE: This is a placeholder. Implementation requires multipart form data.
  /// Will be implemented in a future task once file upload is set up.
  ///
  /// Returns: {profilePictureUrl: string}
  static Future<Map<String, dynamic>> uploadProfilePicture({
    required String authToken,
    required String fileName,
    required String filePath,
  }) async {
    try {
      // TODO: Implement multipart form data upload when file handling is added
      // For now, throw error with implementation note
      throw ApiException(
        message:
            'Profile picture upload not yet implemented. File upload feature coming soon.',
      );

      // Expected implementation:
      // var request = http.MultipartRequest('POST',
      //   Uri.parse('$baseUrl/employee/profile/picture'));
      // request.files.add(await http.MultipartFile.fromPath(
      //   'profilePicture', filePath));
      // request.headers['Authorization'] = 'Bearer $authToken';
      // var response = await request.send();
      // return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get resume URL (if uploaded)
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {resumeUrl: string} or empty if not uploaded
  static Future<Map<String, dynamic>> getResume({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/profile/resume',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload resume PDF file
  ///
  /// [authToken] - Auth token (required)
  /// [fileName] - Name of the resume file (e.g., "resume.pdf")
  /// [filePath] - Local file path to resume
  ///
  /// NOTE: This is a placeholder. Implementation requires multipart form data.
  /// Will be implemented in a future task once file upload is set up.
  ///
  /// Returns: {resumeUrl: string}
  static Future<Map<String, dynamic>> uploadResume({
    required String authToken,
    required String fileName,
    required String filePath,
  }) async {
    try {
      // TODO: Implement multipart form data upload when file handling is added
      throw ApiException(
        message:
            'Resume upload not yet implemented. File upload feature coming soon.',
      );

      // Expected implementation:
      // var request = http.MultipartRequest('POST',
      //   Uri.parse('$baseUrl/employee/profile/resume'));
      // request.files.add(await http.MultipartFile.fromPath(
      //   'resume', filePath));
      // request.headers['Authorization'] = 'Bearer $authToken';
      // var response = await request.send();
      // return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete resume
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {message}
  static Future<Map<String, dynamic>> deleteResume({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.delete(
        '/employee/profile/resume',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete profile picture
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {message}
  static Future<Map<String, dynamic>> deleteProfilePicture({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.delete(
        '/employee/profile/picture',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Add a skill to profile
  ///
  /// [authToken] - Auth token (required)
  /// [skill] - Skill name to add
  ///
  /// Returns: Updated profile with all skills
  static Future<EmployeeProfileModel> addSkill({
    required String authToken,
    required String skill,
  }) async {
    try {
      final response = await ApiService.post(
        '/employee/profile/skills',
        body: {'skill': skill},
        authToken: authToken,
      );

      return EmployeeProfileModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a skill from profile
  ///
  /// [authToken] - Auth token (required)
  /// [skill] - Skill name to remove
  ///
  /// Returns: Updated profile with remaining skills
  static Future<EmployeeProfileModel> removeSkill({
    required String authToken,
    required String skill,
  }) async {
    try {
      final response = await ApiService.delete(
        '/employee/profile/skills/$skill',
        authToken: authToken,
      );

      return EmployeeProfileModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get profile completion suggestions
  ///
  /// [authToken] - Auth token (required)
  ///
  /// Returns: {percentage: int, suggestions: [string], nextStep: string}
  static Future<Map<String, dynamic>> getCompletionSuggestions({
    required String authToken,
  }) async {
    try {
      final response = await ApiService.get(
        '/employee/profile/completion-suggestions',
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Mark profile as public/searchable
  ///
  /// [authToken] - Auth token (required)
  /// [isPublic] - true to make public, false to make private
  ///
  /// Returns: {isPublic: bool, message}
  static Future<Map<String, dynamic>> setProfileVisibility({
    required String authToken,
    required bool isPublic,
  }) async {
    try {
      final response = await ApiService.put(
        '/employee/profile/visibility',
        body: {'isPublic': isPublic},
        authToken: authToken,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
