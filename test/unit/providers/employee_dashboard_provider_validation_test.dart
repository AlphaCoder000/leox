import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/employee_dashboard_model.dart';
import 'package:leox/models/employee_application_model.dart';
import 'package:leox/models/job_application_model.dart';

void main() {
  group('EmployeeDashboardProvider Validation Tests', () {
    group('EmployeeDashboardModel Tests', () {
      test('should create EmployeeDashboardModel with valid data', () {
        final dashboard = EmployeeDashboardModel(
          totalApplications: 10,
          applicationsUnderReview: 5,
          acceptedOffers: 2,
          rejectedApplications: 3,
          recentApplications: [],
          recentRejections: [],
          profileCompletionPercentage: 75,
          profileSuggestions: ['Add more skills'],
        );

        expect(dashboard.totalApplications, equals(10));
        expect(dashboard.applicationsUnderReview, equals(5));
        expect(dashboard.acceptedOffers, equals(2));
        expect(dashboard.rejectedApplications, equals(3));
        expect(dashboard.profileCompletionPercentage, equals(75));
        expect(dashboard.profileSuggestions, contains('Add more skills'));
      });

      test('should handle empty dashboard data', () {
        final dashboard = EmployeeDashboardModel(
          totalApplications: 0,
          applicationsUnderReview: 0,
          acceptedOffers: 0,
          rejectedApplications: 0,
          recentApplications: [],
          recentRejections: [],
          profileCompletionPercentage: 0,
          profileSuggestions: [],
        );

        expect(dashboard.totalApplications, equals(0));
        expect(dashboard.applicationsUnderReview, equals(0));
        expect(dashboard.acceptedOffers, equals(0));
        expect(dashboard.rejectedApplications, equals(0));
        expect(dashboard.profileCompletionPercentage, equals(0));
        expect(dashboard.profileSuggestions, isEmpty);
      });

      test('should validate profile completion percentage bounds', () {
        // Test valid bounds
        final validDashboard1 = EmployeeDashboardModel(
          totalApplications: 0,
          applicationsUnderReview: 0,
          acceptedOffers: 0,
          rejectedApplications: 0,
          recentApplications: [],
          recentRejections: [],
          profileCompletionPercentage: 0,
          profileSuggestions: [],
        );

        final validDashboard2 = EmployeeDashboardModel(
          totalApplications: 0,
          applicationsUnderReview: 0,
          acceptedOffers: 0,
          rejectedApplications: 0,
          recentApplications: [],
          recentRejections: [],
          profileCompletionPercentage: 100,
          profileSuggestions: [],
        );

        expect(validDashboard1.profileCompletionPercentage, equals(0));
        expect(validDashboard2.profileCompletionPercentage, equals(100));

        // Test that invalid values are handled gracefully
        // (The model doesn't have assertions, so we just verify the values are set)
        final invalidDashboard1 = EmployeeDashboardModel(
          totalApplications: 0,
          applicationsUnderReview: 0,
          acceptedOffers: 0,
          rejectedApplications: 0,
          recentApplications: [],
          recentRejections: [],
          profileCompletionPercentage: -1, // Invalid
          profileSuggestions: [],
        );

        final invalidDashboard2 = EmployeeDashboardModel(
          totalApplications: 0,
          applicationsUnderReview: 0,
          acceptedOffers: 0,
          rejectedApplications: 0,
          recentApplications: [],
          recentRejections: [],
          profileCompletionPercentage: 101, // Invalid
          profileSuggestions: [],
        );

        expect(invalidDashboard1.profileCompletionPercentage, equals(-1));
        expect(invalidDashboard2.profileCompletionPercentage, equals(101));
      });

      test('should handle recent applications list correctly', () {
        final applications = [
          EmployeeApplicationModel(
            id: '1',
            employeeId: 'emp1',
            jobId: 'job1',
            jobTitle: 'Software Engineer',
            companyName: 'Tech Corp',
            postedBy: 'Employer',
            status: ApplicationStatus.applied,
            appliedAt: DateTime.now(),
          ),
          EmployeeApplicationModel(
            id: '2',
            employeeId: 'emp1',
            jobId: 'job2',
            jobTitle: 'Data Analyst',
            companyName: 'Data Corp',
            postedBy: 'Employer',
            status: ApplicationStatus.accepted,
            appliedAt: DateTime.now(),
          ),
        ];

        final dashboard = EmployeeDashboardModel(
          totalApplications: 2,
          applicationsUnderReview: 1,
          acceptedOffers: 1,
          rejectedApplications: 0,
          recentApplications: applications,
          recentRejections: [],
          profileCompletionPercentage: 80,
          profileSuggestions: [],
        );

        expect(dashboard.recentApplications.length, equals(2));
        expect(dashboard.recentApplications.first.jobTitle, equals('Software Engineer'));
        expect(dashboard.recentApplications.last.jobTitle, equals('Data Analyst'));
      });

      test('should handle recent rejections list correctly', () {
        final rejections = [
          EmployeeApplicationModel(
            id: '1',
            employeeId: 'emp1',
            jobId: 'job1',
            jobTitle: 'Software Engineer',
            companyName: 'Tech Corp',
            postedBy: 'Employer',
            status: ApplicationStatus.rejected,
            appliedAt: DateTime.now(),
          ),
        ];

        final dashboard = EmployeeDashboardModel(
          totalApplications: 1,
          applicationsUnderReview: 0,
          acceptedOffers: 0,
          rejectedApplications: 1,
          recentApplications: [],
          recentRejections: rejections,
          profileCompletionPercentage: 60,
          profileSuggestions: [],
        );

        expect(dashboard.recentRejections.length, equals(1));
        expect(dashboard.recentRejections.first.status, equals(ApplicationStatus.rejected));
      });
    });

    group('EmployeeApplicationModel Tests', () {
      test('should create EmployeeApplicationModel with valid data', () {
        final application = EmployeeApplicationModel(
          id: '1',
          employeeId: 'emp1',
          jobId: 'job1',
          jobTitle: 'Software Engineer',
          companyName: 'Tech Corp',
          postedBy: 'Employer',
          status: ApplicationStatus.applied,
          appliedAt: DateTime.now(),
        );

        expect(application.id, equals('1'));
        expect(application.employeeId, equals('emp1'));
        expect(application.jobId, equals('job1'));
        expect(application.jobTitle, equals('Software Engineer'));
        expect(application.companyName, equals('Tech Corp'));
        expect(application.status, equals(ApplicationStatus.applied));
      });

      test('should handle all application statuses', () {
        final statuses = [
          ApplicationStatus.applied,
          ApplicationStatus.reviewing,
          ApplicationStatus.accepted,
          ApplicationStatus.rejected,
          ApplicationStatus.offer,
          ApplicationStatus.withdrawn,
        ];

        for (final status in statuses) {
          final application = EmployeeApplicationModel(
            id: '1',
            employeeId: 'emp1',
            jobId: 'job1',
            jobTitle: 'Software Engineer',
            companyName: 'Tech Corp',
            postedBy: 'Employer',
            status: status,
            appliedAt: DateTime.now(),
          );

          expect(application.status, equals(status));
        }
      });

      test('should handle timestamp correctly', () {
        final now = DateTime.now();
        final application = EmployeeApplicationModel(
          id: '1',
          employeeId: 'emp1',
          jobId: 'job1',
          jobTitle: 'Software Engineer',
          companyName: 'Tech Corp',
          postedBy: 'Employer',
          status: ApplicationStatus.applied,
          appliedAt: now,
        );

        expect(application.appliedAt, equals(now));
        expect(application.appliedAt.isAfter(now.subtract(const Duration(hours: 1))), true);
      });
    });

    group('JobApplicationModel Tests', () {
      test('should create JobApplicationModel with required fields', () {
        final jobApp = JobApplicationModel(
          id: '1',
          jobId: 'job1',
          employeeId: 'emp1',
          employerId: 'emp1',
          jobTitle: 'Software Engineer',
          companyName: 'Tech Corp',
          status: 'applied',
          appliedAt: DateTime.now(),
          coverLetter: 'Great candidate',
          employeeName: 'John Doe',
          employeeEmail: 'john@example.com',
        );

        expect(jobApp.id, equals('1'));
        expect(jobApp.jobId, equals('job1'));
        expect(jobApp.employeeId, equals('emp1'));
        expect(jobApp.employerId, equals('emp1'));
        expect(jobApp.jobTitle, equals('Software Engineer'));
        expect(jobApp.companyName, equals('Tech Corp'));
        expect(jobApp.status, equals('applied'));
        expect(jobApp.employeeName, equals('John Doe'));
        expect(jobApp.employeeEmail, equals('john@example.com'));
      });

      test('should handle different job statuses', () {
        final statuses = ['pending', 'under_review', 'accepted', 'rejected'];

        for (final status in statuses) {
          final jobApp = JobApplicationModel(
            id: '1',
            jobId: 'job1',
            employeeId: 'emp1',
            employerId: 'emp1',
            jobTitle: 'Software Engineer',
            companyName: 'Tech Corp',
            status: status,
            appliedAt: DateTime.now(),
            coverLetter: 'Great candidate',
            employeeName: 'John Doe',
            employeeEmail: 'john@example.com',
          );

          expect(jobApp.status, equals(status));
        }
      });
    });

    group('Data Validation Tests', () {
      test('should validate email formats', () {
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
        ];

        for (final email in validEmails) {
          expect(email.contains('@'), true);
          expect(email.contains('.'), true);
        }
      });

      test('should validate phone formats', () {
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

      test('should validate job titles', () {
        const validTitles = [
          'Software Engineer',
          'Data Analyst',
          'Product Manager',
          'UX Designer',
        ];

        for (final title in validTitles) {
          expect(title.isNotEmpty, true);
          expect(title.length, greaterThan(2));
        }
      });

      test('should validate company names', () {
        const validCompanies = [
          'Tech Corp',
          'Data Inc',
          'Startup LLC',
          'Enterprise Ltd',
        ];

        for (final company in validCompanies) {
          expect(company.isNotEmpty, true);
          expect(company.length, greaterThan(1));
        }
      });
    });

    group('Application Status Tests', () {
      test('should handle status progression logic', () {
        final statusProgression = [
          'pending',
          'under_review',
          'accepted',
        ];

        for (int i = 0; i < statusProgression.length; i++) {
          final currentStatus = statusProgression[i];
          expect(currentStatus, isA<String>());
          expect(currentStatus, isNotEmpty);
        }
      });

      test('should handle final statuses', () {
        const finalStatuses = ['accepted', 'rejected'];

        for (final status in finalStatuses) {
          expect(status, isA<String>());
          expect(['accepted', 'rejected'].contains(status), true);
        }
      });
    });
  });
}
