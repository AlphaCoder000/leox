import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/job_application_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('JobApplicationModel', () {
    test('Constructor should initialize properly', () {
      final now = DateTime.now();
      final app = JobApplicationModel(
        id: '1',
        jobId: 'j1',
        employeeId: 'e1',
        employerId: 'em1',
        coverLetter: 'cover',
        appliedAt: now,
        employeeName: 'Name',
        employeeEmail: 'email',
        jobTitle: 'Job Title',
      );

      expect(app.status, 'pending');
      expect(app.matchScore, 0.0);
    });

    test('Display methods behavior', () {
      final now = DateTime.utc(2022, 1, 1);
      final app = JobApplicationModel(id: '', jobId: '', employeeId: '', employerId: '', coverLetter: '', appliedAt: now, employeeName: '', employeeEmail: '', jobTitle: '', status: 'hired');

      expect(app.statusDisplay, 'Hired');
      expect(app.statusColor(), Colors.purple);
    });

    test('toJson serialization', () {
      final now = DateTime.utc(2022, 1, 1);
      final app = JobApplicationModel(id: '', jobId: 'j1', employeeId: '', employerId: '', coverLetter: '', appliedAt: now, employeeName: '', employeeEmail: '', jobTitle: '');

      final map = app.toFirestore();
      expect(map['jobId'], 'j1');
      expect(map['appliedAt'], isA<Timestamp>());
    });
  });
}
