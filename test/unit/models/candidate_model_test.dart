import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/candidate_model.dart';

void main() {
  group('CandidateModel', () {
    test('Constructor should set defaults correctly', () {
      final now = DateTime.now();
      final candidate = CandidateModel(
        id: '1',
        appliedAt: now,
        avatarUrl: 'url',
        email: 'test@example.com',
        jobAppliedFor: 'job_1',
        employeeId: 'emp_1',
        employerId: 'emplyr_1',
        name: 'John Doe',
        phone: '1234567890',
        resumeUrl: 'resume_url',
        skills: ['Flutter'],
      );

      expect(candidate.status, 'pending');
      expect(candidate.matchScore, 0.0);
      expect(candidate.matchReasoning, 'AI analysis not performed.');
    });

    test('toFirestore should serialize correctly', () {
      final now = DateTime.utc(2023, 1, 1);
      final candidate = CandidateModel(
        id: '1',
        appliedAt: now,
        avatarUrl: 'url',
        email: 'test@example.com',
        jobAppliedFor: 'job_1',
        employeeId: 'emp_1',
        employerId: 'emplyr_1',
        name: 'John Doe',
        phone: '1234567890',
        resumeUrl: 'resume_url',
        skills: ['Flutter'],
        status: 'reviewed',
      );

      final map = candidate.toFirestore();
      
      expect(map['email'], 'test@example.com');
      expect(map['employeeId'], 'emp_1');
      expect(map['skills'], ['Flutter']);
      expect(map['status'], 'reviewed');
    });

    test('Display logic and colors should return correct mapping', () {
      final candidatePending = CandidateModel(id: '', appliedAt: DateTime.now(), avatarUrl: '', email: '', jobAppliedFor: '', employeeId: '', employerId: '', name: '', phone: '', resumeUrl: '', skills: [], status: 'pending');
      final candidateHired = CandidateModel(id: '', appliedAt: DateTime.now(), avatarUrl: '', email: '', jobAppliedFor: '', employeeId: '', employerId: '', name: '', phone: '', resumeUrl: '', skills: [], status: 'hired');

      expect(candidatePending.statusDisplay, 'Pending Review');
      expect(candidatePending.statusColor(), Colors.orange);

      expect(candidateHired.statusDisplay, 'Hired');
      expect(candidateHired.statusColor(), Colors.purple);
    });

    test('statusWithDays logic', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final candidate = CandidateModel(id: '', appliedAt: yesterday, avatarUrl: '', email: '', jobAppliedFor: '', employeeId: '', employerId: '', name: '', phone: '', resumeUrl: '', skills: []);
      
      expect(candidate.statusWithDays(), 'Applied Yesterday');
    });
  });
}
