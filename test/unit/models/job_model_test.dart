import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/job_model.dart';

void main() {
  group('JobModel', () {
    test('Constructor should initialize fields and defaults', () {
      final now = DateTime.now();
      final job = JobModel(
        title: 'Software Engineer',
        department: 'Engineering',
        category: 'IT',
        description: 'Great job',
        requirements: ['Dart'],
        postedOn: now,
      );

      expect(job.id, '');
      expect(job.title, 'Software Engineer');
      expect(job.experienceLevel, 'entry'); // default
      expect(job.postedOn, now);
      expect(job.status, 'Open'); // default
      expect(job.candidates, isEmpty);
    });

    test('Equality and HashCode should be based on title', () {
      final now = DateTime.now();
      final job1 = JobModel(
        title: 'Developer',
        department: 'Engineering',
        category: 'IT',
        description: 'Desc',
        requirements: [],
        postedOn: now,
      );

      final job2 = JobModel(
        title: 'Developer', // Same title
        department: 'Other',
        category: 'Other',
        description: 'Other Desc',
        requirements: [],
        postedOn: now,
      );

      final job3 = JobModel(
        title: 'Manager', // Different title
        department: 'Engineering',
        category: 'IT',
        description: 'Desc',
        requirements: [],
        postedOn: now,
      );

      expect(job1, equals(job2));
      expect(job1.hashCode, equals(job2.hashCode));
      expect(job1, isNot(equals(job3)));
    });

    test('toString formats correctly', () {
      final job = JobModel(
        title: 'Developer',
        companyName: 'Google',
        status: 'Open',
        department: '',
        category: '',
        description: '',
        requirements: [],
        postedOn: DateTime.now(),
      );

      expect(job.toString(), 'JobModel(title: Developer, company: Google, status: Open)');
    });
  });
}
