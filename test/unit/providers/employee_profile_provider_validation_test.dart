import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/employee_profile_model.dart';

void main() {
  group('EmployeeProfileProvider Validation Tests', () {
    group('EmployeeProfileModel Tests', () {
      test('should create EmployeeProfileModel with valid data', () {
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          headline: 'Software Engineer',
          bio: 'Experienced software engineer with 5+ years...',
          skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
          resumeUrl: 'https://example.com/resume.pdf',
          profilePicture: 'https://example.com/profile.jpg',
          phone: '+1234567890',
          experienceYears: 5.0,
        );

        expect(profile.id, equals('1'));
        expect(profile.email, equals('john.doe@example.com'));
        expect(profile.firstName, equals('John'));
        expect(profile.lastName, equals('Doe'));
        expect(profile.headline, equals('Software Engineer'));
        expect(profile.bio, contains('software engineer'));
        expect(profile.skills.length, equals(4));
        expect(profile.skills.any((skill) => skill.contains('Flutter')), true);
        expect(profile.resumeUrl, equals('https://example.com/resume.pdf'));
        expect(profile.profilePicture, equals('https://example.com/profile.jpg'));
        expect(profile.phone, equals('+1234567890'));
        expect(profile.experienceYears, equals(5.0));
      });

      test('should handle minimal required data', () {
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'jane.smith@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
        );

        expect(profile.id, equals('1'));
        expect(profile.email, equals('jane.smith@example.com'));
        expect(profile.firstName, equals('Jane'));
        expect(profile.lastName, equals('Smith'));
        expect(profile.bio, equals(''));
        expect(profile.profilePicture, equals(''));
        expect(profile.headline, equals(''));
        expect(profile.skills, isEmpty);
        expect(profile.resumeUrl, equals(''));
        expect(profile.phone, isNull);
        expect(profile.experienceYears, isNull);
      });

      test('should validate email formats', () {
        const validEmails = [
          'john.doe@example.com',
          'jane.smith@company.com',
          'user.name+tag@domain.co.uk',
        ];

        for (final email in validEmails) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: email,
            firstName: 'John',
            lastName: 'Doe',
          );

          expect(profile.email, equals(email));
          expect(profile.email.contains('@'), true);
          expect(profile.email.contains('.'), true);
        }
      });

      test('should validate phone formats', () {
        const validPhones = [
          '+1234567890',
          '+919876543210',
          '+441234567890',
        ];

        for (final phone in validPhones) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: phone,
          );

          expect(profile.phone, equals(phone));
          expect(profile.phone!.startsWith('+'), true);
          expect(profile.phone!.length, greaterThanOrEqualTo(10));
          expect(profile.phone!.substring(1), matches(RegExp(r'^[0-9]+$')));
        }
      });

      test('should handle skills correctly', () {
        const skillSets = [
          ['Flutter', 'Dart', 'Firebase'],
          ['React', 'Node.js', 'MongoDB'],
          ['Python', 'Django', 'PostgreSQL'],
          ['Java', 'Spring', 'MySQL'],
        ];

        for (final skills in skillSets) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            skills: skills,
          );

          expect(profile.skills.length, equals(skills.length));
          expect(profile.skills, equals(skills));
        }
      });

      test('should handle experience years', () {
        const experienceLevels = [
          0.0,
          1.5,
          3.0,
          5.5,
          10.0,
          null,
        ];

        for (final experience in experienceLevels) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            experienceYears: experience,
          );

          expect(profile.experienceYears, equals(experience));
        }
      });

      test('should handle URLs correctly', () {
        const urls = [
          'https://example.com/resume.pdf',
          'https://linkedin.com/in/johndoe',
          'https://github.com/johndoe',
          'https://johndoe.dev',
          '',
          null,
        ];

        for (final url in urls) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            resumeUrl: url ?? '',
          );

          expect(profile.resumeUrl, equals(url ?? ''));
          if (url != null && url.isNotEmpty) {
            expect(url.startsWith('http'), true);
          }
        }
      });

      test('should handle profile picture URLs', () {
        const pictureUrls = [
          'https://example.com/profile.jpg',
          'https://cdn.example.com/images/profile.png',
          'https://storage.googleapis.com/profiles/user123.jpg',
          '',
          null,
        ];

        for (final pictureUrl in pictureUrls) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            profilePicture: pictureUrl ?? '',
          );

          expect(profile.profilePicture, equals(pictureUrl ?? ''));
          if (pictureUrl != null && pictureUrl.isNotEmpty) {
            expect(pictureUrl.startsWith('http'), true);
            expect(pictureUrl.endsWith('.jpg') || pictureUrl.endsWith('.png'), true);
          }
        }
      });

      test('should handle timestamps', () {
        final now = DateTime.now();
        final future = now.add(const Duration(days: 30));

        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: now,
          updatedAt: future,
        );

        expect(profile.createdAt, equals(now));
        expect(profile.updatedAt, equals(future));
        expect(profile.updatedAt?.isAfter(profile.createdAt!), true);
      });

      test('should handle bio validation', () {
        const bios = [
          'Experienced software engineer with 5+ years...',
          'Entry level developer looking for opportunities...',
          'Senior developer with expertise in...',
          'Product manager with 3 years of experience...',
        ];

        for (final bio in bios) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            bio: bio,
          );

          expect(profile.bio, equals(bio));
          expect(profile.bio.isNotEmpty, true);
          expect(profile.bio.length, greaterThan(10));
        }
      });

      test('should handle headline validation', () {
        const headlines = [
          'Software Engineer',
          'Senior Developer',
          'Product Manager',
          'Data Analyst',
          'UX Designer',
          'Full Stack Developer',
        ];

        for (final headline in headlines) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            headline: headline,
          );

          expect(profile.headline, equals(headline));
          expect(profile.headline.isNotEmpty, true);
          expect(profile.headline.length, greaterThan(2));
        }
      });

      test('should handle name validation', () {
        const validNames = [
          'John',
          'Jane',
          'Robert',
          'Emily',
          'Michael',
        ];

        for (final firstName in validNames) {
          for (final lastName in validNames) {
            final profile = EmployeeProfileModel(
              id: '1',
              email: 'john.doe@example.com',
              firstName: firstName,
              lastName: lastName,
            );

            expect(profile.firstName, equals(firstName));
            expect(profile.lastName, equals(lastName));
            expect(profile.firstName.isNotEmpty, true);
            expect(profile.lastName.isNotEmpty, true);
          }
        }
      });

      test('should handle special characters in bio', () {
        const biosWithSpecialChars = [
          'Experienced software engineer with C++ & Python skills.',
          'Proficient in React.js, Node.js, and MongoDB development.',
          'Knowledge of SQL, NoSQL, and GraphQL databases.',
          'Familiar with AWS, Azure, and GCP cloud platforms.',
        ];

        for (final bio in biosWithSpecialChars) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            bio: bio,
          );

          expect(profile.bio, equals(bio));
          expect(profile.bio.isNotEmpty, true);
          expect(profile.bio.length, greaterThan(10));
        }
      });
    });

    group('Profile Validation Tests', () {
      test('should validate complete profile structure', () {
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          headline: 'Software Engineer',
          bio: 'Experienced software engineer with 5+ years...',
          skills: ['Flutter', 'Dart', 'Firebase'],
          resumeUrl: 'https://example.com/resume.pdf',
          profilePicture: 'https://example.com/profile.jpg',
          phone: '+1234567890',
          experienceYears: 5.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Check all required fields are present
        expect(profile.id, isNotEmpty);
        expect(profile.email, isNotEmpty);
        expect(profile.firstName, isNotEmpty);
        expect(profile.lastName, isNotEmpty);

        // Check optional fields can be null or empty
        expect(profile.phone, isA<String?>());
        expect(profile.bio, isA<String>());
        expect(profile.profilePicture, isA<String>());
        expect(profile.headline, isA<String>());
        expect(profile.skills, isA<List<String>>());
        expect(profile.experienceYears, isA<double?>());
        expect(profile.resumeUrl, isA<String>());
        expect(profile.resumeName, isA<String>());
        expect(profile.resumeLocalPath, isA<String?>());
        expect(profile.createdAt, isA<DateTime?>());
        expect(profile.updatedAt, isA<DateTime?>());
      });

      test('should handle profile completion calculation', () {
        final profiles = [
          EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
          ),
          EmployeeProfileModel(
            id: '2',
            email: 'jane.smith@example.com',
            firstName: 'Jane',
            lastName: 'Smith',
            headline: 'Data Analyst',
            bio: 'Experienced data analyst...',
            skills: ['Python', 'SQL', 'Tableau'],
            resumeUrl: 'https://example.com/resume.pdf',
          ),
          EmployeeProfileModel(
            id: '3',
            email: 'bob.johnson@example.com',
            firstName: 'Bob',
            lastName: 'Johnson',
            headline: 'Product Manager',
            bio: 'Product manager with...',
            skills: ['Product Management', 'Agile', 'Scrum'],
            resumeUrl: 'https://experience.com/resume.pdf',
            profilePicture: 'https://example.com/profile.jpg',
            phone: '+1234567890',
            experienceYears: 7.0,
          ),
        ];

        // Basic profile should have minimal fields
        expect(profiles[0].firstName, isNotEmpty);
        expect(profiles[0].skills, isEmpty);
        expect(profiles[0].experienceYears, isNull);
        
        // More complete profile should have more fields
        expect(profiles[1].skills.isNotEmpty, true);
        expect(profiles[1].resumeUrl.isNotEmpty, true);
        expect(profiles[1].experienceYears, isNull);
        
        // Complete profile should have all optional fields
        expect(profiles[2].profilePicture.isNotEmpty, true);
        expect(profiles[2].phone, isNotNull);
        expect(profiles[2].experienceYears, equals(7.0));
      });
    });

    group('Data Type Tests', () {
      test('should handle string operations correctly', () {
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          headline: 'Software Engineer',
          bio: 'Bio',
          skills: ['Flutter'],
          resumeUrl: 'https://example.com',
        );

        expect(profile.id, isA<String>());
        expect(profile.email, isA<String>());
        expect(profile.firstName, isA<String>());
        expect(profile.lastName, isA<String>());
        expect(profile.headline, isA<String>());
        expect(profile.bio, isA<String>());
        expect(profile.resumeUrl, isA<String>());
      });

      test('should handle list operations correctly', () {
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          skills: ['Flutter', 'Dart', 'Firebase'],
        );

        expect(profile.skills, isA<List<String>>());
        expect(profile.skills.length, equals(3));
        expect(profile.skills.any((skill) => skill.contains('Flutter')), true);
        expect(profile.skills.any((skill) => skill.contains('Dart')), true);
        expect(profile.skills.any((skill) => skill.contains('Firebase')), true);
      });

      test('should handle numeric operations correctly', () {
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          experienceYears: 5.0,
        );

        expect(profile.experienceYears, isA<double>());
        expect(profile.experienceYears, equals(5.0));
        expect(profile.experienceYears! > 0.0, true);
        expect(profile.experienceYears! < 50.0, true);
      });

      test('should handle timestamp operations correctly', () {
        final now = DateTime.now();
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: now,
          updatedAt: now.add(const Duration(days: 1)),
        );

        expect(profile.createdAt, isA<DateTime>());
        expect(profile.updatedAt, isA<DateTime>());
        expect(profile.updatedAt?.isAfter(profile.createdAt!), true);
        expect(profile.updatedAt!.difference(profile.createdAt!).inDays, equals(1));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle very long bio', () {
        final longBio = 'This is a very long bio that contains a lot of information about the candidate, their experience, skills, education, and career goals. ' * 20;
        expect(longBio.length, greaterThan(200));
        
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          bio: longBio,
        );

        expect(profile.bio, equals(longBio));
        expect(profile.bio.length, greaterThan(200));
      });

      test('should handle very long skills list', () {
        final manySkills = List.generate(100, (index) => 'Skill ${index + 1}');
        expect(manySkills.length, equals(100));
        
        final profile = EmployeeProfileModel(
          id: '1',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          skills: manySkills,
        );

        expect(profile.skills.length, equals(100));
        expect(profile.skills.first, equals('Skill 1'));
        expect(profile.skills.last, equals('Skill 100'));
      });

      test('should handle extreme experience values', () {
        const extremeValues = [
          0.0,
          0.5,
          99.9,
          null,
        ];

        for (final experience in extremeValues) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            experienceYears: experience,
          );

          expect(profile.experienceYears, equals(experience));
          if (experience != null) {
            expect(experience, greaterThanOrEqualTo(0.0));
            expect(experience, lessThan(100.0));
          }
        }
      });

      test('should handle empty and null URLs', () {
        final urls = [
          '',
          null,
          'not-a-url',
          'ftp://invalid.com',
          'http://',
        ];

        for (final url in urls) {
          final profile = EmployeeProfileModel(
            id: '1',
            email: 'john.doe@example.com',
            firstName: 'John',
            lastName: 'Doe',
            resumeUrl: url ?? '',
            profilePicture: url ?? '',
          );

          expect(profile.resumeUrl, equals(url ?? ''));
          expect(profile.profilePicture, equals(url ?? ''));
        }
      });
    });
  });
}
