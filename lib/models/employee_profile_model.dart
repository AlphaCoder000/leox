/// Employee Profile Model
///
/// Separate from employer profile to support different fields
/// (skills, resume, experience, certifications, etc.)
///
/// This is a data-only class with JSON serialization support.
library;
import 'package:flutter/foundation.dart';

class EmployeeProfileModel {
  // ======== ESSENTIAL INFO ========
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;

  // ======== PROFILE INFO ========
  final String bio;
  final String profilePicture; // URL or local path
  final String headline; // Current job title / role (e.g., "Senior Developer")

  // ======== PROFESSIONAL INFO ========
  final List<String> skills; // e.g., ["Flutter", "Firebase", "Dart"]
  final double? experienceYears; // Total years of experience
  final String resumeUrl; // URL to uploaded resume PDF
  final String? resumeLocalPath; // Local path during upload

  // ======== TIMESTAMPS ========
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Constructor with named parameters
  EmployeeProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.bio = '',
    this.profilePicture = '',
    this.headline = '',
    this.skills = const [],
    this.experienceYears,
    this.resumeUrl = '',
    this.resumeLocalPath,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (API response)
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": "emp_123",
  ///   "email": "user@example.com",
  ///   "phone": "+919876543210",
  ///   "firstName": "John",
  ///   "lastName": "Doe",
  ///   "bio": "Passionate developer...",
  ///   "profilePicture": "https://...",
  ///   "headline": "Senior Flutter Developer",
  ///   "skills": ["Flutter", "Firebase"],
  ///   "experienceYears": 5,
  ///   "resumeUrl": "https://...pdf",
  ///   "createdAt": "2025-01-15T10:30:00Z",
  ///   "updatedAt": "2025-01-20T14:45:00Z"
  /// }
  /// ```
  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      bio: json['bio'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      headline: json['headline'] ?? '',
      skills: _parseSkills(json['skills']),
      experienceYears: _parseDouble(json['experienceYears']),
      resumeUrl: json['resumeUrl'] ?? '',
      resumeLocalPath: json['resumeLocalPath'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Convert to JSON (for API requests)
  ///
  /// NOTE: Does not include read-only fields (id, createdAt, updatedAt)
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (bio.isNotEmpty) 'bio': bio,
      if (profilePicture.isNotEmpty) 'profilePicture': profilePicture,
      if (headline.isNotEmpty) 'headline': headline,
      if (skills.isNotEmpty) 'skills': skills,
      if (experienceYears != null) 'experienceYears': experienceYears,
      if (resumeUrl.isNotEmpty) 'resumeUrl': resumeUrl,
    };
  }

  /// Create a copy with modified fields
  ///
  /// Useful for local state updates before API calls
  EmployeeProfileModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? bio,
    String? profilePicture,
    String? headline,
    List<String>? skills,
    double? experienceYears,
    String? resumeUrl,
    String? resumeLocalPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      headline: headline ?? this.headline,
      skills: skills ?? this.skills,
      experienceYears: experienceYears ?? this.experienceYears,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeLocalPath: resumeLocalPath ?? this.resumeLocalPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if profile is complete (has required fields for a good profile)
  ///
  /// Returns true if profile has at least: bio, headline, skills, resume
  bool get isComplete {
    return bio.isNotEmpty &&
    headline.isNotEmpty &&
    skills.isNotEmpty &&
    resumeUrl.isNotEmpty;
  }

  /// Profile completion percentage (0-100)
  ///
  /// Based on how many optional fields are filled
 int get completionPercentage {
  int filled = 0;
  int total = 6; // bio, headline, skills, experience, resume, profilePicture

  if (bio.isNotEmpty) filled++;
  if (headline.isNotEmpty) filled++;
  if (skills.isNotEmpty) filled++;
  if (experienceYears != null && experienceYears! > 0) filled++;
  if (resumeUrl.isNotEmpty) filled++;
  if (profilePicture.isNotEmpty) filled++;

  return ((filled / total) * 100).toInt();
}


  /// Create empty profile model
  static EmployeeProfileModel empty() {
    return EmployeeProfileModel(
      id: '',
      email: '',
      firstName: '',
      lastName: '',
      skills: [],
    );
  }

  @override
  String toString() =>
      'EmployeeProfileModel(id: $id, email: $email, name: $fullName, completion: $completionPercentage%)';

  // ======== HELPER FUNCTIONS ========

  /// Parse skills list from JSON (handles null, empty, or invalid data)
  static List<String> _parseSkills(dynamic skillsData) {
    if (skillsData == null) return [];
    if (skillsData is List) {
      return skillsData.whereType<String>().toList(); // Filter only strings
    }
    return [];
  }

  /// Parse double value from JSON (handles null, int, double, string)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse DateTime from ISO 8601 string
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('[EmployeeProfileModel] Failed to parse date: $value');
        return null;
      }
    }
    return null;
  }
}
