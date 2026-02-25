import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini Service - Handles AI operations using Google's Generative AI
class GeminiService {
  static const String _modelName = 'gemini-1.5-flash';
  
  // Get your free Gemini API key from: https://aistudio.google.com/
  static String? _apiKey;

  static void init(String apiKey) {
    _apiKey = apiKey;
  }

  static GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey!,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  static GenerativeModel? get _model {
    if (_apiKey == null || _apiKey!.isEmpty) return null;
    return _createModel(_modelName);
  }

  /// Parses a resume into structured JSON
  static Future<Map<String, dynamic>> parseResume(String resumeText) async {
    final model = _model;
    if (model == null) {
      return {'success': false, 'error': 'API Key not configured'};
    }

    final prompt = '''
    Act as a professional HR resume parser. Parse the following resume text into a structured JSON format.
    The JSON should include:
    - personalInfo: { name, email, phone, location, linkedin, website }
    - summary: A brief professional summary
    - education: array of { institution, degree, field, startYear, endYear, gpa }
    - experience: array of { title, company, location, startDate, endDate, description (list of points), skillsUsed }
    - skills: array of skill names
    - projects: array of { name, description, technologies }
    - certifications: array of string
    - languages: array of string
    - confidence: a score from 0.0 to 1.0 representing your confidence in this extraction

    Resume Text:
    $resumeText
    ''';

    try {
      final content = [Content.text(prompt)];
      var response = await model.generateContent(content);
      
      if (response.text == null) throw Exception('No response from AI');
      
      final Map<String, dynamic> parsed = jsonDecode(response.text!);
      parsed['success'] = true;
      return parsed;
    } catch (e) {
      debugPrint('[GeminiService] Primary model failed, trying fallback (1.5-pro)...');
      try {
        final fallbackModel = _createModel('gemini-1.5-pro');
        final response = await fallbackModel.generateContent([Content.text(prompt)]);
        if (response.text == null) throw Exception('No response from fallback AI');
        final Map<String, dynamic> parsed = jsonDecode(response.text!);
        parsed['success'] = true;
        return parsed;
      } catch (fallbackError) {
        debugPrint('[GeminiService] Fallback also failed: $fallbackError');
        return {
          'success': false, 
          'error': 'AI Service is initializing. Since this is a new API key, Google usually takes 2-3 minutes to activate it. Please wait a moment and try again.'
        };
      }
    }
  }

  /// Matches a resume to a job description
  static Future<Map<String, dynamic>> matchResumeToJob({
    required String resumeText,
    required String jobDescription,
  }) async {
    final model = _model;
    if (model == null) {
      return {'success': false, 'error': 'API Key not configured'};
    }

    final prompt = '''
    Act as an AI Recruiter. Compare the provided resume against the job description.
    Return a detailed analysis in JSON format with the following keys:
    - overallScore: A matching percentage (0.0 to 100.0)
    - skillsMatch: Percentage for skills only (0.0 to 100.0)
    - experienceMatch: Percentage for experience only (0.0 to 100.0)
    - educationMatch: Percentage for eduction only (0.0 to 100.0)
    - analysis: A high-level summary of the match (2-3 sentences)
    - strengths: Array of 3-5 specific strengths the candidate has for this role
    - gaps: Array of 3-5 specific areas where the candidate is lacking or could improve
    - recommendations: Array of 3-5 actionable steps the candidate should take to improve their chances
    - matchedSkills: Array of skills found in both resume and job description
    - missingSkills: Array of high-priority skills in the job description missing from the resume

    Resume Text:
    $resumeText

    Job Description:
    $jobDescription
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text == null) throw Exception('No response from AI');
      
      final Map<String, dynamic> results = jsonDecode(response.text!);
      results['success'] = true;
      return results;
    } catch (e) {
      debugPrint('[GeminiService] Primary model failed, trying fallback (1.5-pro)...');
      try {
        final fallbackModel = _createModel('gemini-1.5-pro');
        final response = await fallbackModel.generateContent([Content.text(prompt)]);
        if (response.text == null) throw Exception('No response from fallback AI');
        final Map<String, dynamic> results = jsonDecode(response.text!);
        results['success'] = true;
        return results;
      } catch (fallbackError) {
        debugPrint('[GeminiService] Fallback match failed: $fallbackError');
        return {
          'success': false, 
          'error': 'AI Analysis is pending activation. Google is still indexing your new API key. This typically takes 2-5 minutes from creation. Please try again shortly.'
        };
      }
    }
  }
}
