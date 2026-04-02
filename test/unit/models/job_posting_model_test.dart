import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/job_posting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('JobPostingModel', () {
    test('Constructor and defaults', () {
      final now = DateTime.now();
      final job = JobPostingModel(
        id: '1',
        title: 'Developer',
        department: 'Engineering',
        description: 'Code things',
        employerId: 'emp1',
        companyName: 'Tech Co',
        location: 'Remote',
        jobType: 'full-time',
        salary: '100k',
        postedAt: now,
      );

      expect(job.status, 'active');
      expect(job.experienceLevel, 'entry');
      expect(job.applicationCount, 0);
    });

    test('Display logic for UI', () {
      final job = JobPostingModel(
        id: '1',
        title: 'Developer',
        department: 'Engineering',
        description: 'Desc',
        employerId: 'emp1',
        companyName: 'Tech Co',
        location: 'Remote',
        jobType: 'internship',
        experienceLevel: 'senior',
        salary: '100k',
        postedAt: DateTime.now(),
        status: 'closed',
      );

      expect(job.jobTypeDisplay, 'Internship');
      expect(job.experienceLevelDisplay, 'Senior Level');
      expect(job.statusDisplay, 'Closed');
    });

    test('isAcceptingApplications logic', () {
      final now = DateTime.now();
      
      // Active with future deadline
      final job1 = JobPostingModel(id: '1', title: '', department: '', description: '', employerId: '', companyName: '', location: '', jobType: '', salary: '', postedAt: now, status: 'active', deadline: now.add(const Duration(days: 5)));
      expect(job1.isAcceptingApplications, isTrue);

      // Inactive
      final job2 = job1.copyWith(status: 'inactive');
      expect(job2.isAcceptingApplications, isFalse);

      // Active with past deadline
      final job3 = job1.copyWith(deadline: now.subtract(const Duration(days: 1)));
      expect(job3.isAcceptingApplications, isFalse);
    });

    test('toFirestore serialization', () {
      final now = DateTime.utc(2023, 1, 1);
      final job = JobPostingModel(id: '1', title: 'Dev', department: 'Eng', description: 'desc', employerId: 'e', companyName: 'c', location: 'l', jobType: 'j', salary: 's', postedAt: now, deadline: now.add(const Duration(days: 1)));
      
      final map = job.toFirestore();
      expect(map['title'], 'Dev');
      expect(map['postedAt'], isA<Timestamp>());
      expect(map['deadline'], isA<Timestamp>());
    });
  });
}
