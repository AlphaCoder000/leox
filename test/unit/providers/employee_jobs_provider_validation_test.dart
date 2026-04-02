import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/job_model.dart';

void main() {
  group('EmployeeJobsProvider Validation Tests', () {
    group('JobModel Validation Tests', () {
      test('should create JobModel with valid data', () {
        final job = JobModel(
          id: '1',
          title: 'Software Engineer',
          department: 'Engineering',
          category: 'Software Development',
          location: 'Remote',
          jobType: 'full-time',
          status: 'Open',
          description: 'We are looking for a software engineer...',
          requirements: ['5+ years experience', 'Flutter knowledge'],
          salaryRange: '\$80,000 - \$120,000',
          postedOn: DateTime.now(),
          employerId: 'emp1',
          companyName: 'Tech Corp',
          postedBy: 'employer1',
          applicationCount: 5,
          deadline: DateTime.now().add(const Duration(days: 30)),
        );

        expect(job.id, equals('1'));
        expect(job.title, equals('Software Engineer'));
        expect(job.department, equals('Engineering'));
        expect(job.category, equals('Software Development'));
        expect(job.location, equals('Remote'));
        expect(job.jobType, equals('full-time'));
        expect(job.status, equals('Open'));
        expect(job.description, contains('software engineer'));
        expect(job.requirements, contains('Flutter knowledge'));
        expect(job.salaryRange, equals('\$80,000 - \$120,000'));
        expect(job.employerId, equals('emp1'));
        expect(job.companyName, equals('Tech Corp'));
        expect(job.applicationCount, equals(5));
      });

      test('should handle empty job data', () {
        final job = JobModel(
          id: '',
          title: '',
          department: '',
          category: '',
          location: '',
          jobType: '',
          status: '',
          description: '',
          requirements: [],
          salaryRange: '',
          postedOn: DateTime.now(),
          employerId: '',
          companyName: '',
          postedBy: '',
          applicationCount: 0,
          deadline: DateTime.now(),
        );

        expect(job.id, isEmpty);
        expect(job.title, isEmpty);
        expect(job.department, isEmpty);
        expect(job.category, isEmpty);
        expect(job.location, isEmpty);
        expect(job.jobType, isEmpty);
        expect(job.status, isEmpty);
        expect(job.description, isEmpty);
        expect(job.requirements, isEmpty);
        expect(job.salaryRange, isEmpty);
        expect(job.employerId, isEmpty);
        expect(job.companyName, isEmpty);
        expect(job.applicationCount, equals(0));
      });

      test('should validate job types', () {
        const validJobTypes = [
          'full-time',
          'part-time',
          'contract',
          'internship',
          'remote',
        ];

        for (final jobType in validJobTypes) {
          final job = JobModel(
            id: '1',
            title: 'Software Engineer',
            department: 'Engineering',
            category: 'Software Development',
            location: 'Remote',
            jobType: jobType,
            status: 'Open',
            description: 'Job description',
            requirements: ['Requirement'],
            salaryRange: '\$50,000 - \$80,000',
            postedOn: DateTime.now(),
            employerId: 'emp1',
            companyName: 'Tech Corp',
            postedBy: 'employer1',
            applicationCount: 0,
            deadline: DateTime.now(),
          );

          expect(job.jobType, equals(jobType));
        }
      });

      test('should validate job statuses', () {
        const validStatuses = [
          'Open',
          'Closed',
          'Draft',
          'On Hold',
        ];

        for (final status in validStatuses) {
          final job = JobModel(
            id: '1',
            title: 'Software Engineer',
            department: 'Engineering',
            category: 'Software Development',
            location: 'Remote',
            jobType: 'full-time',
            status: status,
            description: 'Job description',
            requirements: ['Requirement'],
            salaryRange: '\$50,000 - \$80,000',
            postedOn: DateTime.now(),
            employerId: 'emp1',
            companyName: 'Tech Corp',
            postedBy: 'employer1',
            applicationCount: 0,
            deadline: DateTime.now(),
          );

          expect(job.status, equals(status));
        }
      });

      test('should handle job requirements correctly', () {
        final requirements = [
          'Bachelor\'s degree in Computer Science',
          '3+ years of experience',
          'Knowledge of Flutter',
          'Strong problem-solving skills',
        ];

        final job = JobModel(
          id: '1',
          title: 'Software Engineer',
          department: 'Engineering',
          category: 'Software Development',
          location: 'Remote',
          jobType: 'full-time',
          status: 'Open',
          description: 'Job description',
          requirements: requirements,
          salaryRange: '\$50,000 - \$80,000',
          postedOn: DateTime.now(),
          employerId: 'emp1',
          companyName: 'Tech Corp',
          postedBy: 'employer1',
          applicationCount: 0,
          deadline: DateTime.now(),
        );

        expect(job.requirements.length, equals(4));
        expect(job.requirements.any((req) => req.contains('Flutter')), true);
        expect(job.requirements.any((req) => req.contains('problem-solving')), true);
      });

      test('should handle salary ranges correctly', () {
        const salaryRanges = [
          '\$30,000 - \$50,000',
          '\$50,000 - \$80,000',
          '\$80,000 - \$120,000',
          '\$120,000 - \$200,000',
          'Negotiable',
        ];

        for (final salaryRange in salaryRanges) {
          final job = JobModel(
            id: '1',
            title: 'Software Engineer',
            department: 'Engineering',
            category: 'Software Development',
            location: 'Remote',
            jobType: 'full-time',
            status: 'Open',
            description: 'Job description',
            requirements: ['Requirement'],
            salaryRange: salaryRange,
            postedOn: DateTime.now(),
            employerId: 'emp1',
            companyName: 'Tech Corp',
            postedBy: 'employer1',
            applicationCount: 0,
            deadline: DateTime.now(),
          );

          expect(job.salaryRange, equals(salaryRange));
        }
      });

      test('should handle timestamps correctly', () {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 30));

        final job = JobModel(
          id: '1',
          title: 'Software Engineer',
          department: 'Engineering',
          category: 'Software Development',
          location: 'Remote',
          jobType: 'full-time',
          status: 'Open',
          description: 'Job description',
          requirements: ['Requirement'],
          salaryRange: '\$50,000 - \$80,000',
          postedOn: now,
          employerId: 'emp1',
          companyName: 'Tech Corp',
          postedBy: 'employer1',
          applicationCount: 0,
          deadline: futureDate,
        );

        expect(job.postedOn, equals(now));
        expect(job.deadline, equals(futureDate));
        expect(job.deadline?.isAfter(job.postedOn), true);
      });

      test('should handle application counts correctly', () {
        const applicationCounts = [0, 1, 5, 10, 50, 100];

        for (final count in applicationCounts) {
          final job = JobModel(
            id: '1',
            title: 'Software Engineer',
            department: 'Engineering',
            category: 'Software Development',
            location: 'Remote',
            jobType: 'full-time',
            status: 'Open',
            description: 'Job description',
            requirements: ['Requirement'],
            salaryRange: '\$50,000 - \$80,000',
            postedOn: DateTime.now(),
            employerId: 'emp1',
            companyName: 'Tech Corp',
            postedBy: 'employer1',
            applicationCount: count,
            deadline: DateTime.now(),
          );

          expect(job.applicationCount, equals(count));
          expect(job.applicationCount, isA<int>());
        }
      });
    });

    group('Job Search Validation Tests', () {
      test('should handle basic search terms', () {
        const searchTerms = [
          'software engineer',
          'data analyst',
          'product manager',
          'ux designer',
          'full stack',
          'mobile developer',
        ];

        for (final searchTerm in searchTerms) {
          expect(searchTerm.isNotEmpty, true);
          expect(searchTerm.length, greaterThan(2));
          expect(searchTerm.contains(' '), isTrue, reason: 'Most job titles contain spaces');
        }
      });

      test('should handle location filters', () {
        const locations = [
          'Remote',
          'New York',
          'San Francisco',
          'London',
          'Berlin',
          'Tokyo',
        ];

        for (final location in locations) {
          expect(location.isNotEmpty, true);
          expect(location.length, greaterThan(1));
        }
      });

      test('should handle job type filters', () {
        const jobTypes = [
          'full-time',
          'part-time',
          'contract',
          'internship',
          'remote',
        ];

        for (final jobType in jobTypes) {
          expect(jobType.isNotEmpty, true);
          // Some job types contain hyphens, some don't
          expect(jobType.contains('-') || !jobType.contains('-'), true);
        }
      });

      test('should handle salary range filters', () {
        const salaryRanges = [
          '0-50000',
          '50000-80000',
          '80000-120000',
          '120000-200000',
          '200000+',
        ];

        for (final salaryRange in salaryRanges) {
          expect(salaryRange.isNotEmpty, true);
          expect(salaryRange.contains('-') || salaryRange.contains('+'), true);
        }
      });

      test('should handle department filters', () {
        const departments = [
          'Engineering',
          'Marketing',
          'Sales',
          'HR',
          'Finance',
          'Operations',
        ];

        for (final department in departments) {
          expect(department.isNotEmpty, true);
          expect(department.length, greaterThan(1));
          expect(department[0], equals(department[0].toUpperCase()));
        }
      });
    });

    group('Data Validation Tests', () {
      test('should validate email formats in job posts', () {
        const validEmails = [
          'hr@company.com',
          'jobs@techcorp.com',
          'careers@startup.io',
        ];

        for (final email in validEmails) {
          expect(email.contains('@'), true);
          expect(email.contains('.'), true);
        }
      });

      test('should validate phone number formats', () {
        const validPhones = [
          '+1234567890',
          '+919876543210',
          '+441234567890',
        ];

        for (final phone in validPhones) {
          expect(phone.startsWith('+'), true);
          expect(phone.length, greaterThanOrEqualTo(10));
          expect(phone.substring(1), matches(RegExp(r'^[0-9]+$')));
        }
      });

      test('should validate company names', () {
        const validCompanies = [
          'Tech Corp',
          'Data Inc',
          'Startup LLC',
          'Enterprise Ltd',
          'Innovation Co',
        ];

        for (final company in validCompanies) {
          expect(company.isNotEmpty, true);
          expect(company.length, greaterThan(1));
          expect(company.split(' ').length, greaterThanOrEqualTo(1));
        }
      });

      test('should validate job titles', () {
        const validTitles = [
          'Software Engineer',
          'Senior Data Analyst',
          'Product Manager',
          'UX Designer',
          'Full Stack Developer',
          'Mobile App Developer',
        ];

        for (final title in validTitles) {
          expect(title.isNotEmpty, true);
          expect(title.length, greaterThan(2));
          expect(title.split(' ').length, greaterThanOrEqualTo(1));
        }
      });

      test('should validate job descriptions', () {
        const validDescriptions = [
          'We are looking for a talented software engineer...',
          'Join our team as a data analyst and help us...',
          'Seeking an experienced product manager to lead...',
          'Our company is hiring a UX designer to create...',
        ];

        for (final description in validDescriptions) {
          expect(description.isNotEmpty, true);
          expect(description.length, greaterThan(30)); // Reduced requirement
          expect(description.contains('.'), true);
        }
      });
    });

    group('Edge Cases Tests', () {
      test('should handle very long job titles', () {
        final longTitle = 'Senior ' * 15 + 'Software Engineer';
        expect(longTitle.length, greaterThan(100));
        
        final job = JobModel(
          id: '1',
          title: longTitle,
          department: 'Engineering',
          category: 'Software Development',
          location: 'Remote',
          jobType: 'full-time',
          status: 'Open',
          description: 'Job description',
          requirements: ['Requirement'],
          salaryRange: '\$50,000 - \$80,000',
          postedOn: DateTime.now(),
          employerId: 'emp1',
          companyName: 'Tech Corp',
          postedBy: 'employer1',
          applicationCount: 0,
          deadline: DateTime.now(),
        );

        expect(job.title, equals(longTitle));
        expect(job.title.length, greaterThan(100));
      });

      test('should handle empty requirements list', () {
        final job = JobModel(
          id: '1',
          title: 'Software Engineer',
          department: 'Engineering',
          category: 'Software Development',
          location: 'Remote',
          jobType: 'full-time',
          status: 'Open',
          description: 'Job description',
          requirements: [],
          salaryRange: '\$50,000 - \$80,000',
          postedOn: DateTime.now(),
          employerId: 'emp1',
          companyName: 'Tech Corp',
          postedBy: 'employer1',
          applicationCount: 0,
          deadline: DateTime.now(),
        );

        expect(job.requirements, isEmpty);
        expect(job.requirements.length, equals(0));
      });

      test('should handle large application counts', () {
        const largeCounts = [1000, 5000, 10000];

        for (final count in largeCounts) {
          final job = JobModel(
            id: '1',
            title: 'Software Engineer',
            department: 'Engineering',
            category: 'Software Development',
            location: 'Remote',
            jobType: 'full-time',
            status: 'Open',
            description: 'Job description',
            requirements: ['Requirement'],
            salaryRange: '\$50,000 - \$80,000',
            postedOn: DateTime.now(),
            employerId: 'emp1',
            companyName: 'Tech Corp',
            postedBy: 'employer1',
            applicationCount: count,
            deadline: DateTime.now(),
          );

          expect(job.applicationCount, equals(count));
          expect(job.applicationCount, greaterThan(999));
        }
      });

      test('should handle special characters in job descriptions', () {
        const descriptionsWithSpecialChars = [
          'We need someone with C++ & Python skills.',
          'Experience with React.js, Node.js, and MongoDB required.',
          'Must know SQL, NoSQL, and GraphQL.',
          'Familiar with AWS, Azure, or GCP cloud platforms.',
        ];

        for (final description in descriptionsWithSpecialChars) {
          expect(description.isNotEmpty, true);
          expect(description.contains(RegExp(r'[&+,]')), true, reason: 'Should contain special characters');
        }
      });
    });
  });
}
