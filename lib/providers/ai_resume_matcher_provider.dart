import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../backend/ai_workflows.dart';
import '../services/storage_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
class AIResumeMatcherProvider extends ChangeNotifier {
  final AIWorkflows _aiWorkflows = AIWorkflows();

  // ======== STATE VARIABLES ========
  bool _isAnalyzing = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedResumeFileName;
  String? _selectedResumeUrl;
  String? _selectedResumeText;
  Map<String, dynamic> _matchResults = {};
  String _jobDescription = '';
  String _errorMessage = '';

  // ======== GETTERS ========
  bool get isAnalyzing => _isAnalyzing;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get selectedResumeFileName => _selectedResumeFileName;
  String? get selectedResumeUrl => _selectedResumeUrl;
  String? get selectedResumeText => _selectedResumeText;
  Map<String, dynamic> get matchResults => _matchResults;
  String get jobDescription => _jobDescription;
  String get errorMessage => _errorMessage;

  // ======== METHODS ========

  /// Update job description
  void updateJobDescription(String description) {
    _jobDescription = description;
    notifyListeners();
  }

  /// Pick resume file
  Future<bool> pickResumeFile() async {
    try {
      debugPrint('[AIResumeMatcherProvider] Picking resume file');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
        allowMultiple: false,
        withData: true, // 🚨 CRITICAL: Required for mobile to get file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) {
          _errorMessage = 'File is empty or corrupted';
          notifyListeners();
          return false;
        }
        _selectedResumeFileName = file.name;
        _isUploading = true;
        _uploadProgress = 0.0;
        _errorMessage = '';
        _selectedResumeText = null; // Reset text
        notifyListeners();
        
        // --- STEP 1: Text Extraction (Local) ---
        if (file.extension?.toLowerCase() == 'pdf') {
          try {
            debugPrint('[AIResumeMatcherProvider] Extracting text from PDF...');
            final PdfDocument document = PdfDocument(inputBytes: file.bytes);
            final String text = PdfTextExtractor(document).extractText();
            document.dispose();
            _selectedResumeText = text;
            debugPrint('[AIResumeMatcherProvider] PDF text extracted successfully (${text.length} chars)');
          } catch (e) {
            debugPrint('[AIResumeMatcherProvider] PDF extraction error: $e');
            // Continue to upload, maybe backend can handle it
          }
        } else if (file.extension?.toLowerCase() == 'txt') {
          _selectedResumeText = String.fromCharCodes(file.bytes!);
        }

        // --- STEP 2: Upload to Storage (Parallel) ---
        _uploadProgress = 0.2;
        notifyListeners();
        
        // Upload to Firebase Storage
        final storageService = StorageService();
        final downloadUrl = await storageService.uploadFileBytes(
          fileBytes: file.bytes!,
          fileName: file.name,
          folder: 'ai-resume-analysis',
        );

        _isUploading = false;
        _uploadProgress = 1.0;

        if (downloadUrl != null) {
          _selectedResumeUrl = downloadUrl;
          _errorMessage = '';
          notifyListeners();
          debugPrint('[AIResumeMatcherProvider] Resume uploaded successfully: $downloadUrl');
          return true;
        } else {
          _errorMessage = 'Failed to upload resume';
          notifyListeners();
          return false;
        }
      }
      return false;
    } catch (e) {
      _isUploading = false;
      _errorMessage = 'Error picking file: ${e.toString()}';
      notifyListeners();
      debugPrint('[AIResumeMatcherProvider] Error picking file: $e');
      return false;
    }
  }

  /// Parse resume using AI
  Future<bool> parseResume() async {
    if (_selectedResumeUrl == null && _selectedResumeText == null) {
      _errorMessage = 'Please upload a resume or paste resume text';
      notifyListeners();
      return false;
    }

    try {
      _isAnalyzing = true;
      _errorMessage = '';
      notifyListeners();

      debugPrint('[AIResumeMatcherProvider] Parsing resume...');

      final result = await _aiWorkflows.parseResume(
        resumeFileUrl: _selectedResumeUrl,
        resumeText: _selectedResumeText,
      );

      if (result['success'] == true) {
        _matchResults = {
          'parsed': true,
          'personalInfo': result['personalInfo'] ?? {},
          'education': result['education'] ?? [],
          'experience': result['experience'] ?? [],
          'skills': result['skills'] ?? [],
          'projects': result['projects'] ?? [],
          'certifications': result['certifications'] ?? [],
          'languages': result['languages'] ?? [],
          'summary': result['summary'] ?? '',
          'confidence': result['confidence'] ?? 0.0,
        };
        _errorMessage = '';
        debugPrint('[AIResumeMatcherProvider] Resume parsed successfully');
      } else {
        _errorMessage = result['error'] ?? 'Failed to parse resume';
        debugPrint('[AIResumeMatcherProvider] Resume parsing failed: ${result['error']}');
      }

      _isAnalyzing = false;
      notifyListeners();
      return result['success'] == true;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = 'Error parsing resume: ${e.toString()}';
      notifyListeners();
      debugPrint('[AIResumeMatcherProvider] Error parsing resume: $e');
      return false;
    }
  }

  /// Match resume to job description
  Future<bool> matchResumeToJob() async {
    if (_selectedResumeUrl == null && _selectedResumeText == null) {
      _errorMessage = 'Please upload a resume or paste resume text';
      notifyListeners();
      return false;
    }

    if (_jobDescription.isEmpty) {
      _errorMessage = 'Please provide a job description';
      notifyListeners();
      return false;
    }

    try {
      _isAnalyzing = true;
      _errorMessage = '';
      notifyListeners();

      debugPrint('[AIResumeMatcherProvider] Matching resume to job...');

      final result = await _aiWorkflows.matchResumeToJob(
        resumeUrl: _selectedResumeUrl,
        resumeText: _selectedResumeText,
        jobDescription: _jobDescription,
        resumeData: _matchResults['parsed'] == true ? _matchResults : null,
      );

      if (result['success'] == true) {
        _matchResults = {
          'matched': true,
          'overallScore': result['overallScore'] ?? 0.0,
          'skillsMatch': result['skillsMatch'] ?? 0.0,
          'experienceMatch': result['experienceMatch'] ?? 0.0,
          'educationMatch': result['educationMatch'] ?? 0.0,
          'analysis': result['analysis'] ?? '',
          'strengths': result['strengths'] ?? [],
          'gaps': result['gaps'] ?? [],
          'recommendations': result['recommendations'] ?? [],
          'matchedSkills': result['matchedSkills'] ?? [],
          'missingSkills': result['missingSkills'] ?? [],
        };
        _errorMessage = '';
        debugPrint('[AIResumeMatcherProvider] Resume matching completed');
      } else {
        _errorMessage = result['error'] ?? 'Failed to match resume';
        debugPrint('[AIResumeMatcherProvider] Resume matching failed: ${result['error']}');
      }

      _isAnalyzing = false;
      notifyListeners();
      return result['success'] == true;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = 'Error matching resume: ${e.toString()}';
      notifyListeners();
      debugPrint('[AIResumeMatcherProvider] Error matching resume: $e');
      return false;
    }
  }

  /// Update resume text (for paste option)
  void updateResumeText(String text) {
    _selectedResumeText = text;
    _selectedResumeFileName = 'Pasted Resume';
    _selectedResumeUrl = null;
    notifyListeners();
  }

  /// Clear all data
  void clearAll() {
    _isAnalyzing = false;
    _selectedResumeFileName = null;
    _selectedResumeUrl = null;
    _selectedResumeText = null;
    _matchResults = {};
    _jobDescription = '';
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Get score color based on percentage
  String getScoreColor(double score) {
    if (score >= 80) return '#4CAF50'; // Green
    if (score >= 60) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  /// Get score grade
  String getScoreGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'B+';
    if (score >= 75) return 'B';
    if (score >= 70) return 'C+';
    if (score >= 65) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}
