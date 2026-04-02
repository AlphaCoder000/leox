import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/employee_profile_model.dart';

void main() {
  group('EmployeeProfileModel', () {
    test('empty() should return an empty profile', () {
      final profile = EmployeeProfileModel.empty();
      
      expect(profile.id, isEmpty);
      expect(profile.email, isEmpty);
      expect(profile.firstName, isEmpty);
      expect(profile.lastName, isEmpty);
      expect(profile.skills, isEmpty);
      expect(profile.fullName, ' ');
    });

    test('fromJson() should correctly parse JSON data', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'bio': 'Test bio',
        'skills': ['Flutter', 'Dart'],
        'experienceYears': 5.5,
        'createdAt': '2023-01-01T12:00:00Z',
      };

      final profile = EmployeeProfileModel.fromJson(json);

      expect(profile.id, '123');
      expect(profile.email, 'test@example.com');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.bio, 'Test bio');
      expect(profile.skills, ['Flutter', 'Dart']);
      expect(profile.experienceYears, 5.5);
      expect(profile.createdAt?.year, 2023);
    });

    test('toJson() should correctly serialize data', () {
      final profile = EmployeeProfileModel(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        bio: 'Test bio',
        skills: ['Flutter'],
        experienceYears: 5.5,
      );

      final json = profile.toJson();

      expect(json['firstName'], 'John');
      expect(json['email'], 'test@example.com');
      expect(json['bio'], 'Test bio');
      expect(json['skills'], ['Flutter']);
      expect(json['experienceYears'], 5.5);
      expect(json['id'], isNull); // 'id' is not serialized in toJson
    });

    test('copyWith() should correctly update fields', () {
      final profile = EmployeeProfileModel.empty();
      final updatedProfile = profile.copyWith(
        firstName: 'Alice',
        experienceYears: 2.0,
      );

      expect(updatedProfile.firstName, 'Alice');
      expect(updatedProfile.lastName, '');
      expect(updatedProfile.experienceYears, 2.0);
    });

    test('isComplete and completionPercentage should calculate correctly', () {
      var profile = EmployeeProfileModel.empty();
      expect(profile.isComplete, isFalse);
      expect(profile.completionPercentage, 0);

      profile = profile.copyWith(
        bio: 'Bio',
        headline: 'Developer',
        skills: ['Dart'],
        experienceYears: 2,
        resumeUrl: 'http://example.com/resume.pdf',
        profilePicture: 'http://example.com/pic.jpg',
      );

      expect(profile.isComplete, isTrue);
      // bio (1) + headline (1) + skills (1) + experience (1) + resume (1) + pic (1) = 6/6 = 100%
      expect(profile.completionPercentage, 100);
    });

    test('_parseDouble and _parseSkills handle edge cases using fromJson', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'skills': 'Not A List', // Invalid skills format
        'experienceYears': '3', // String format for double
      };

      final profile = EmployeeProfileModel.fromJson(json);

      expect(profile.skills, isEmpty); // Should fallback to empty list
      expect(profile.experienceYears, 3.0); // Should parse string to double
    });
  });
}
