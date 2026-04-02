import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/employee_application_model.dart';

void main() {
  group('EmployeeApplicationModel', () {
    test('Constructor should initialize fields correctly', () {
      final now = DateTime.now();
      final model = EmployeeApplicationModel(
        id: '1',
        employeeId: 'emp1',
        jobId: 'job1',
        jobTitle: 'Developer',
        companyName: 'Tech',
        postedBy: 'Admin',
        status: ApplicationStatus.reviewing,
        appliedAt: now,
      );

      expect(model.jobTitle, 'Developer');
      expect(model.status, ApplicationStatus.reviewing);
    });

    test('Color and Status Labels map correctly', () {
      final model1 = EmployeeApplicationModel(id: '', employeeId: '', jobId: '', jobTitle: '', companyName: '', postedBy: '', status: ApplicationStatus.rejected, appliedAt: DateTime.now());
      
      expect(model1.statusColor(), Colors.red[600]);
      expect(model1.statusLabel(), 'Rejected');
      expect(model1.isActive, isFalse);
    });

    test('fromJson and toJson', () {
      final json = {
        'id': '1',
        'employeeId': 'emp1',
        'jobId': 'job1',
        'jobTitle': 'Developer',
        'companyName': 'Tech',
        'postedBy': 'Admin',
        'status': 'accepted',
        'appliedAt': '2025-01-01T12:00:00Z'
      };

      final model = EmployeeApplicationModel.fromJson(json);
      expect(model.status, ApplicationStatus.accepted);
      expect(model.appliedAt.year, 2025);

      final map = model.toJson();
      expect(map['status'], 'accepted');
      expect(map['employeeId'], 'emp1');
      // toJson drops generated fields like id and appliedAt
      expect(map.containsKey('id'), isFalse);
    });
  });
}
