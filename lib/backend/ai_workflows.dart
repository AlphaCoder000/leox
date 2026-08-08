/// AI Workflows - AI-Powered Features
/// Equivalent to web app's src/ai/flows/ directory
/// Contains AI logic for resume parsing, job matching, interview questions
library;

import 'package:flutter/foundation.dart';
import 'package:leox/services/gemini_service.dart';
import 'package:leox/services/session_service.dart';
import '../services/api_service.dart';

class AIWorkflows {
  // ======== RESUME PARSING ========

  /// Parse resume from file or text
  /// Equivalent to web app's parse-resume.ts
  Future<Map<String, dynamic>> parseResume({
    String? resumeFileUrl,
    String? resumeText,
  }) async {
    try {
      debugPrint('[AIWorkflows] Parsing resume');
      
      String textToParse = resumeText ?? '';
      
      // If we have a file URL but no text, we'd ideally extract text here.
      // For now, we assume resumeText is provided or handled by the provider.
      
      if (textToParse.isEmpty && resumeFileUrl != null) {
        // Fallback to API if text extraction isn't available and we have a URL
        final authToken = await SessionService.getAuthToken();
        final result = await ApiService.post('/match-resume', body: {'resumeFileUrl': resumeFileUrl}, authToken: authToken);
        if (result['success'] == true) return result['data'];
        throw Exception('No text available for Gemini parsing');
      }

      // Use Gemini Service for parsing
      final result = await GeminiService.parseResume(textToParse);
      return result;
      
    } catch (e) {
      debugPrint('[AIWorkflows] Error parsing resume: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ======== JOB MATCHING ========

  /// Match resume to job description
  /// Equivalent to web app's ai-match-resume-to-job.ts
  Future<Map<String, dynamic>> matchResumeToJob({
    String? resumeUrl,
    String? resumeText,
    required String jobDescription,
    Map<String, dynamic>? resumeData,
  }) async {
    try {
      debugPrint('[AIWorkflows] Matching resume to job via backend API...');
      
      final authToken = await SessionService.getAuthToken();
      final response = await ApiService.post(
        '/subscription/ai/match-resume',
        body: {
          'resumeText': resumeText ?? '',
          'jobDescription': jobDescription,
        },
        authToken: authToken,
      );

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        data['success'] = true;
        return data;
      }
      
      if (response['rateLimited'] == true) {
        return {
          'success': false,
          'rateLimited': true,
          'error': response['message'] ?? 'AI matching rate limited. Queued for background processing.',
          'overallScore': 0.0,
          'skillsMatch': 0.0,
          'experienceMatch': 0.0,
          'educationMatch': 0.0,
          'analysis': response['message'] ?? 'Queued for background processing.',
        };
      }
      
      throw Exception(response['error'] ?? 'Backend evaluation failed');
      
    } catch (e) {
      debugPrint('[AIWorkflows] Backend matching failed or offline ($e). Falling back to direct client-side Gemini...');
      try {
        final result = await GeminiService.matchResumeToJob(
          resumeText: resumeText ?? '',
          jobDescription: jobDescription,
        );
        return result;
      } catch (fallbackError) {
        debugPrint('[AIWorkflows] Direct client-side matching also failed: $fallbackError');
        return {
          'success': false,
          'error': 'Error generating AI Match: $fallbackError',
          'overallScore': 0.0,
          'skillsMatch': 0.0,
          'experienceMatch': 0.0,
          'educationMatch': 0.0,
          'analysis': 'Failed to evaluate resume after fallback.',
        };
      }
    }
  }

  // ======== INTERVIEW QUESTIONS ========

  /// Generate interview questions
  /// Equivalent to web app's generate-interview-questions.ts
  Future<Map<String, dynamic>> generateInterviewQuestions({
    required String jobDescription,
    required String resumeText,
    required String interviewType,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      debugPrint('[AIWorkflows] Generating interview questions');
      
      final authToken = await SessionService.getAuthToken();
      // Call AI service for question generation
      final result = await ApiService.post('/ai/generate-questions', body: {
        'jobDescription': jobDescription,
        'resumeText': resumeText,
        'interviewType': interviewType,
        'questionCount': questionCount,
        'difficulty': difficulty,
      }, authToken: authToken);
      
      if (result['success'] == true) {
        final questionsData = result['data'] ?? {};
        
        debugPrint('[AIWorkflows] Interview questions generated');
        return {
          'success': true,
          'questions': List<Map<String, dynamic>>.from(questionsData['questions'] ?? []),
          'totalQuestions': questionsData['totalQuestions'] ?? 0,
          'estimatedDuration': questionsData['estimatedDuration'] ?? 30,
          'difficulty': questionsData['difficulty'] ?? difficulty,
          'categories': List<String>.from(questionsData['categories'] ?? []),
        };
      } else {
        throw Exception(result['message'] ?? 'Question generation failed');
      }
    } catch (e) {
      debugPrint('[AIWorkflows] Error generating interview questions: $e');
      return {
        'success': false,
        'error': e.toString(),
        'questions': [],
        'totalQuestions': 0,
        'estimatedDuration': 30,
        'difficulty': difficulty,
        'categories': [],
      };
    }
  }

  // ======== PROFILE OPTIMIZATION ========

  /// Optimize user profile for better job matching
  Future<Map<String, dynamic>> optimizeProfile({
    required Map<String, dynamic> profileData,
    required String targetRole,
    List<String>? targetSkills,
  }) async {
    try {
      debugPrint('[AIWorkflows] Optimizing profile for: $targetRole');
      
      final authToken = await SessionService.getAuthToken();
      // Call AI service for profile optimization
      final result = await ApiService.post('/ai/optimize-profile', body: {
        'profileData': profileData,
        'targetRole': targetRole,
        'targetSkills': targetSkills ?? [],
      }, authToken: authToken);
      
      if (result['success'] == true) {
        final optimizationData = result['data'] ?? {};
        
        debugPrint('[AIWorkflows] Profile optimization completed');
        return {
          'success': true,
          'optimizedProfile': optimizationData['optimizedProfile'] ?? {},
          'suggestions': List<String>.from(optimizationData['suggestions'] ?? []),
          'missingSkills': List<String>.from(optimizationData['missingSkills'] ?? []),
          'recommendedSkills': List<String>.from(optimizationData['recommendedSkills'] ?? []),
          'profileStrength': optimizationData['profileStrength'] ?? 0.0,
          'improvementAreas': List<String>.from(optimizationData['improvementAreas'] ?? []),
        };
      } else {
        throw Exception(result['message'] ?? 'Profile optimization failed');
      }
    } catch (e) {
      debugPrint('[AIWorkflows] Error optimizing profile: $e');
      return {
        'success': false,
        'error': e.toString(),
        'optimizedProfile': {},
        'suggestions': [],
        'missingSkills': [],
        'recommendedSkills': [],
        'profileStrength': 0.0,
        'improvementAreas': [],
      };
    }
  }

  // ======== JOB DESCRIPTION ANALYSIS ========

  /// Analyze job description for insights
  Future<Map<String, dynamic>> analyzeJobDescription({
    required String jobDescription,
    required String jobTitle,
    String? jobCategory,
  }) async {
    try {
      debugPrint('[AIWorkflows] Analyzing job description');
      
      final authToken = await SessionService.getAuthToken();
      // Call AI service for job analysis
      final result = await ApiService.post('/ai/analyze-job', body: {
        'jobDescription': jobDescription,
        'jobTitle': jobTitle,
        'jobCategory': jobCategory,
      }, authToken: authToken);
      
      if (result['success'] == true) {
        final analysisData = result['data'] ?? {};
        
        debugPrint('[AIWorkflows] Job description analysis completed');
        return {
          'success': true,
          'requiredSkills': List<String>.from(analysisData['requiredSkills'] ?? []),
          'preferredSkills': List<String>.from(analysisData['preferredSkills'] ?? []),
          'experienceLevel': analysisData['experienceLevel'] ?? '',
          'salaryRange': analysisData['salaryRange'] ?? {},
          'responsibilities': List<String>.from(analysisData['responsibilities'] ?? []),
          'qualifications': List<String>.from(analysisData['qualifications'] ?? []),
          'companyCulture': analysisData['companyCulture'] ?? '',
          'growthOpportunities': List<String>.from(analysisData['growthOpportunities'] ?? []),
          'workEnvironment': analysisData['workEnvironment'] ?? '',
          'complexity': analysisData['complexity'] ?? 'medium',
        };
      } else {
        throw Exception(result['message'] ?? 'Job analysis failed');
      }
    } catch (e) {
      debugPrint('[AIWorkflows] Error analyzing job description: $e');
      return {
        'success': false,
        'error': e.toString(),
        'requiredSkills': [],
        'preferredSkills': [],
        'experienceLevel': '',
        'salaryRange': {},
        'responsibilities': [],
        'qualifications': [],
        'companyCulture': '',
        'growthOpportunities': [],
        'workEnvironment': '',
        'complexity': 'medium',
      };
    }
  }

  // ======== SKILL ASSESSMENT ========

  /// Assess user skills based on profile and experience
  Future<Map<String, dynamic>> assessSkills({
    required Map<String, dynamic> profileData,
    required List<Map<String, dynamic>> experienceData,
    required List<String> targetSkills,
  }) async {
    try {
      debugPrint('[AIWorkflows] Assessing skills');
      
      final authToken = await SessionService.getAuthToken();
      // Call AI service for skill assessment
      final result = await ApiService.post('/ai/assess-skills', body: {
        'profileData': profileData,
        'experienceData': experienceData,
        'targetSkills': targetSkills,
      }, authToken: authToken);
      
      if (result['success'] == true) {
        final assessmentData = result['data'] ?? {};
        
        debugPrint('[AIWorkflows] Skill assessment completed');
        return {
          'success': true,
          'skillLevels': Map<String, double>.from(assessmentData['skillLevels'] ?? {}),
          'overallScore': assessmentData['overallScore'] ?? 0.0,
          'strengths': List<String>.from(assessmentData['strengths'] ?? []),
          'weaknesses': List<String>.from(assessmentData['weaknesses'] ?? []),
          'recommendations': List<String>.from(assessmentData['recommendations'] ?? []),
          'learningPaths': Map<String, List<String>>.from(assessmentData['learningPaths'] ?? {}),
          'certificationSuggestions': List<String>.from(assessmentData['certificationSuggestions'] ?? []),
        };
      } else {
        throw Exception(result['message'] ?? 'Skill assessment failed');
      }
    } catch (e) {
      debugPrint('[AIWorkflows] Error assessing skills: $e');
      return {
        'success': false,
        'error': e.toString(),
        'skillLevels': {},
        'overallScore': 0.0,
        'strengths': [],
        'weaknesses': [],
        'recommendations': [],
        'learningPaths': {},
        'certificationSuggestions': [],
      };
    }
  }

  // ======== CAREER PATH RECOMMENDATIONS ========

  /// Get career path recommendations based on profile
  Future<Map<String, dynamic>> getCareerRecommendations({
    required Map<String, dynamic> profileData,
    required List<String> interests,
    required List<String> currentSkills,
    String? currentRole,
  }) async {
    try {
      debugPrint('[AIWorkflows] Getting career recommendations');
      
      final authToken = await SessionService.getAuthToken();
      // Call AI service for career recommendations
      final result = await ApiService.post('/ai/career-recommendations', body: {
        'profileData': profileData,
        'interests': interests,
        'currentSkills': currentSkills,
        'currentRole': currentRole,
      }, authToken: authToken);
      
      if (result['success'] == true) {
        final recommendationsData = result['data'] ?? {};
        
        debugPrint('[AIWorkflows] Career recommendations generated');
        return {
          'success': true,
          'recommendedRoles': List<Map<String, dynamic>>.from(recommendationsData['recommendedRoles'] ?? []),
          'skillGaps': List<String>.from(recommendationsData['skillGaps'] ?? []),
          'learningPaths': Map<String, List<String>>.from(recommendationsData['learningPaths'] ?? {}),
          'salaryProjections': Map<String, dynamic>.from(recommendationsData['salaryProjections'] ?? {}),
          'industryTrends': List<String>.from(recommendationsData['industryTrends'] ?? []),
          'nextSteps': List<String>.from(recommendationsData['nextSteps'] ?? []),
          'timeToTransition': recommendationsData['timeToTransition'] ?? {},
        };
      } else {
        throw Exception(result['message'] ?? 'Career recommendations failed');
      }
    } catch (e) {
      debugPrint('[AIWorkflows] Error getting career recommendations: $e');
      return {
        'success': false,
        'error': e.toString(),
        'recommendedRoles': [],
        'skillGaps': [],
        'learningPaths': {},
        'salaryProjections': {},
        'industryTrends': [],
        'nextSteps': [],
        'timeToTransition': {},
      };
    }
  }
}
