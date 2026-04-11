/// Job Application View
///
/// Allows employees to apply for jobs with resume upload
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/job_application_provider.dart';
import '../../models/job_posting_model.dart';
import '../../utils/error_handler_ui.dart';

class JobApplicationView extends StatefulWidget {
  final JobPostingModel job;

  const JobApplicationView({super.key, required this.job});

  @override
  State<JobApplicationView> createState() => _JobApplicationViewState();
}

class _JobApplicationViewState extends State<JobApplicationView> {
  final _coverLetterController = TextEditingController();
  final _experienceController = TextEditingController();
  final _salaryController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  PlatformFile? _selectedResume;
  String _selectedExperience = '0-1 years'; // Default experience

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationProvider>().clearMessages();
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _experienceController.dispose();
    _salaryController.dispose();
    _availabilityController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && mounted) {
        setState(() {
          _selectedResume = result.files.single;
        });

        debugPrint(
          '[JobApplicationView] Selected resume: ${_selectedResume!.name}',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          'Failed to pick resume: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (_coverLetterController.text.trim().isEmpty) {
      ErrorHandlerUI.showErrorSnackbar(context, 'Please write a cover letter');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    // Submit application with optional resume
    final success = await context.read<JobApplicationProvider>().submitApplication(
      jobId: widget.job.id,
      coverLetter: _coverLetterController.text.trim(),
      resumeFile:
          _selectedResume, // Only use uploaded resume, not existing profile resume
      jobPosting: widget.job,
      experience: _selectedExperience,
      expectedSalary: _salaryController.text.trim(),
      availability: _availabilityController.text.trim(),
      linkedIn: _linkedinController.text.trim(),
      portfolio: _portfolioController.text.trim(),
    );

    if (mounted) {
      if (success) {
        if (context.mounted) {
          Navigator.pop(context);
          ErrorHandlerUI.showSuccessSnackbar(
            context,
            'Application submitted successfully!',
          );
        }
      } else {
        if (context.mounted) {
          ErrorHandlerUI.showErrorSnackbar(
            context,
            context.read<JobApplicationProvider>().errorMessage ??
                'Failed to submit application',
          );
        }
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Application'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you ready to submit your application?'),
                SizedBox(height: 1.h),
                if (_selectedResume != null) ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resume: ${_selectedResume!.name}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No resume attached',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Submit Application'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  Widget _buildJobDetailsCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.5.h),

            _buildDetailRow('Title', widget.job.title),
            _buildDetailRow('Department', widget.job.department),
            _buildDetailRow('Type', widget.job.jobType),
            _buildDetailRow('Location', widget.job.location),
            _buildDetailRow('Salary', widget.job.salary),

            if (widget.job.description.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                'Description',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.job.description,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCoverLetterSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cover Letter',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Tell the employer why you\'re perfect for this role',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your cover letter here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Resume',
                  style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Upload your resume to increase your chances of getting hired',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            SizedBox(height: 1.5.h),

            // Resume Upload Area
            if (_selectedResume != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 8.w,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _selectedResume!.name,
                      style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickResume,
                          icon: const Icon(Icons.refresh),
                          label: Text('Change Resume'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedResume = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text('Remove'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 8.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Click to upload your resume',
                      style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'PDF, DOC, DOCX (Max 5MB)',
                      style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.normal,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickResume,
                  icon: const Icon(Icons.upload_file),
                  label: Text('Choose Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationDetailsSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Helps employers know you better',
                    style: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),

            // Experience Level
            Text(
              'Experience Level',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.5.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedExperience,
                  isExpanded: true,
                  hint: Text('Select experience level'),
                  items:
                      [
                        '0-1 years',
                        '1-3 years',
                        '3-5 years',
                        '5-10 years',
                        '10+ years',
                      ].map((experience) {
                        return DropdownMenuItem<String>(
                          value: experience,
                          child: Text(experience),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExperience = value!;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 1.5.h),

            // Expected Salary
            Text(
              'Expected Salary (Optional)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.5.h),
            TextField(
              controller: _salaryController,
              decoration: InputDecoration(
                hintText: 'Enter your expected salary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                prefixIcon: Icon(Icons.attach_money, color: Colors.grey[600]),
              ),
            ),

            SizedBox(height: 1.5.h),

            // Availability
            Text(
              'Availability',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.5.h),
            TextField(
              controller: _availabilityController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'When can you start working? Any preferences?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                prefixIcon: Icon(Icons.schedule, color: Colors.grey[600]),
              ),
            ),

            SizedBox(height: 1.5.h),

            // LinkedIn
            Text(
              'LinkedIn Profile (Optional)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.5.h),
            TextField(
              controller: _linkedinController,
              decoration: InputDecoration(
                hintText: 'https://linkedin.com/in/yourprofile',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                prefixIcon: Icon(Icons.link, color: Colors.grey[600]),
              ),
            ),

            SizedBox(height: 1.5.h),

            // Portfolio
            Text(
              'Portfolio / Other Link (Optional)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.5.h),
            TextField(
              controller: _portfolioController,
              decoration: InputDecoration(
                hintText: 'https://yourportfolio.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                prefixIcon: Icon(Icons.web, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final applicationProvider = context.watch<JobApplicationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.job.title}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Details Card
                _buildJobDetailsCard(context, colorScheme),

                SizedBox(height: 2.h),

                // Cover Letter Section
                _buildCoverLetterSection(context, colorScheme),

                SizedBox(height: 2.h),

                // Resume Section
                _buildResumeSection(context, colorScheme),

                SizedBox(height: 3.h),

                // Additional Application Details
                _buildApplicationDetailsSection(context, colorScheme),

                SizedBox(height: 4.h),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 6.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        applicationProvider.isLoading
                            ? null
                            : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        applicationProvider.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Application',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),

          // Success/Error Messages
          if (applicationProvider.successMessage != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  applicationProvider.successMessage!,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold,),
                ),
              ),
            ),

          if (applicationProvider.errorMessage != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  applicationProvider.errorMessage!,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold,),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
