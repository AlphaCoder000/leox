import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/employee_dashboard_model.dart';

void main() {
  group('EmployeeDashboardModel', () {
    test('applicationSuccessRate should calculate correctly', () {
      final emptyModel = EmployeeDashboardModel.empty();
      expect(emptyModel.applicationSuccessRate(), 0.0);

      final model = EmployeeDashboardModel(
        totalApplications: 10,
        applicationsUnderReview: 0,
        acceptedOffers: 2,
        rejectedApplications: 0,
        recentApplications: [],
        recentRejections: [],
        profileCompletionPercentage: 0,
        profileSuggestions: [],
      );

      expect(model.applicationSuccessRate(), 20.0); // (2/10) * 100
      expect(model.pendingApplications, 8); // 10 - 2 - 0
    });

    test('fromJson parsing', () {
      final json = {
        'stats': {
          'totalApplications': 5,
          'acceptedOffers': 1,
        },
        'profileCompletion': {
          'percentage': 80,
          'suggestions': ['Add photo']
        }
      };

      final model = EmployeeDashboardModel.fromJson(json);
      expect(model.totalApplications, 5);
      expect(model.acceptedOffers, 1);
      expect(model.profileCompletionPercentage, 80);
      expect(model.profileSuggestions, ['Add photo']);
      expect(model.recentApplications, isEmpty);
    });
  });
}
