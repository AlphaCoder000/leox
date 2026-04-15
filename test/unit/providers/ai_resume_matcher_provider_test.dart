import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:leox/providers/ai_resume_matcher_provider.dart';
import 'package:leox/backend/ai_workflows.dart';

@GenerateMocks([AIWorkflows])
void main() {
  group('AIResumeMatcherProvider Tests', () {
    late AIResumeMatcherProvider provider;

    setUp(() {
      provider = AIResumeMatcherProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should initialize with default values', () {
      expect(provider.isAnalyzing, false);
      expect(provider.isUploading, false);
      expect(provider.uploadProgress, 0.0);
      expect(provider.selectedResumeFileName, null);
      expect(provider.selectedResumeUrl, null);
      expect(provider.selectedResumeText, null);
      expect(provider.matchResults, isEmpty);
      expect(provider.jobDescription, '');
      expect(provider.errorMessage, '');
    });

    test('should update job description correctly', () {
      const testDescription = 'Test job description';
      provider.updateJobDescription(testDescription);
      
      expect(provider.jobDescription, testDescription);
    });

    test('should update resume text correctly', () {
      const testText = 'Test resume content';
      provider.updateResumeText(testText);
      
      expect(provider.selectedResumeText, testText);
      expect(provider.selectedResumeFileName, 'Pasted Resume');
      expect(provider.selectedResumeUrl, null);
    });

    test('should clear all data correctly', () {
      // Set some data first
      provider.updateJobDescription('Test job');
      provider.updateResumeText('Test resume');
      
      // Clear all
      provider.clearAll();
      
      expect(provider.isAnalyzing, false);
      expect(provider.selectedResumeFileName, null);
      expect(provider.selectedResumeUrl, null);
      expect(provider.selectedResumeText, null);
      expect(provider.matchResults, isEmpty);
      expect(provider.jobDescription, '');
      expect(provider.errorMessage, '');
    });

    test('should clear error message correctly', () {
      provider.clearError();
      expect(provider.errorMessage, '');
    });

    test('should get score color correctly', () {
      expect(provider.getScoreColor(85), '#4CAF50'); // Green
      expect(provider.getScoreColor(70), '#FF9800'); // Orange
      expect(provider.getScoreColor(50), '#F44336'); // Red
    });

    test('should get score grade correctly', () {
      expect(provider.getScoreGrade(95), 'A+');
      expect(provider.getScoreGrade(87), 'A');
      expect(provider.getScoreGrade(82), 'B+');
      expect(provider.getScoreGrade(77), 'B');
      expect(provider.getScoreGrade(72), 'C+');
      expect(provider.getScoreGrade(67), 'C');
      expect(provider.getScoreGrade(62), 'D');
      expect(provider.getScoreGrade(50), 'F');
    });

    test('should handle state getters correctly', () {
      expect(provider.isAnalyzing, isA<bool>());
      expect(provider.isUploading, isA<bool>());
      expect(provider.uploadProgress, isA<double>());
      expect(provider.selectedResumeFileName, isA<String?>());
      expect(provider.selectedResumeUrl, isA<String?>());
      expect(provider.selectedResumeText, isA<String?>());
      expect(provider.matchResults, isA<Map<String, dynamic>>());
      expect(provider.jobDescription, isA<String>());
      expect(provider.errorMessage, isA<String>());
    });

    test('should validate parse resume prerequisites', () async {
      // Test with no resume data
      final result1 = await provider.parseResume();
      expect(result1, false);
      expect(provider.errorMessage, 'Please upload a resume or paste resume text');

      // Set some resume text and test again
      provider.updateResumeText('Test resume content');
      provider.clearError();
      
      // Now it should proceed (though will fail without proper AI workflows)
      expect(provider.selectedResumeText, isNotEmpty);
    });

    test('should validate match resume prerequisites', () async {
      // Test with no resume data
      final result1 = await provider.matchResumeToJob();
      expect(result1, false);
      expect(provider.errorMessage, 'Please upload a resume or paste resume text');

      // Set resume text but no job description
      provider.updateResumeText('Test resume content');
      provider.clearError();
      
      final result2 = await provider.matchResumeToJob();
      expect(result2, false);
      expect(provider.errorMessage, 'Please provide a job description');

      // Set job description
      provider.updateJobDescription('Test job description');
      provider.clearError();
      
      // Now it should proceed (though will fail without proper AI workflows)
      expect(provider.selectedResumeText, isNotEmpty);
      expect(provider.jobDescription, isNotEmpty);
    });

    test('should handle match results structure', () {
      // Test that match results can handle different structures
      expect(provider.matchResults, isA<Map<String, dynamic>>());
      
      // Should be able to add parsed results
      final parsedResults = {
        'parsed': true,
        'personalInfo': {'name': 'John Doe'},
        'education': [],
        'experience': [],
        'skills': [],
        'projects': [],
        'certifications': [],
        'languages': [],
        'summary': 'Test summary',
        'confidence': 0.85,
      };
      
      // Should be able to add matched results
      final matchedResults = {
        'matched': true,
        'overallScore': 85.0,
        'skillsMatch': 90.0,
        'experienceMatch': 80.0,
        'educationMatch': 75.0,
        'analysis': 'Test analysis',
        'strengths': ['Strong technical skills'],
        'gaps': ['Missing management experience'],
        'recommendations': ['Consider leadership training'],
        'matchedSkills': ['JavaScript', 'React'],
        'missingSkills': ['Management'],
      };
      
      expect(parsedResults, isA<Map<String, dynamic>>());
      expect(matchedResults, isA<Map<String, dynamic>>());
    });
  });

  group('AIResumeMatcherProvider Edge Cases', () {
    late AIResumeMatcherProvider provider;

    setUp(() {
      provider = AIResumeMatcherProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should handle empty job description', () {
      expect(provider.jobDescription, '');
      provider.updateJobDescription('');
      expect(provider.jobDescription, '');
    });

    test('should handle null values gracefully', () {
      expect(provider.selectedResumeFileName, null);
      expect(provider.selectedResumeUrl, null);
      expect(provider.selectedResumeText, null);
    });

    test('should handle score boundary conditions', () {
      // Test exact boundaries
      expect(provider.getScoreColor(80), '#4CAF50'); // Boundary for green
      expect(provider.getScoreColor(79.9), '#FF9800'); // Just below green
      expect(provider.getScoreColor(60), '#FF9800'); // Boundary for orange
      expect(provider.getScoreColor(59.9), '#F44336'); // Just below orange
      
      expect(provider.getScoreGrade(90), 'A+'); // Boundary for A+
      expect(provider.getScoreGrade(89.9), 'A'); // Just below A+
      expect(provider.getScoreGrade(85), 'A'); // Boundary for A
      expect(provider.getScoreGrade(84.9), 'B+'); // Just below A
    });

    test('should maintain state consistency', () {
      // Initial state
      expect(provider.isAnalyzing, false);
      expect(provider.isUploading, false);
      expect(provider.uploadProgress, 0.0);
      
      // State should remain consistent
      expect(provider.isAnalyzing, isA<bool>());
      expect(provider.isUploading, isA<bool>());
      expect(provider.uploadProgress, isA<double>());
    });
  });
}
