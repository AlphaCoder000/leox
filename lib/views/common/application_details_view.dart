import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/candidate_model.dart';
import '../../providers/job_application_provider.dart';
import '../../utils/error_handler_ui.dart';

class JobApplicationDetailsView extends StatefulWidget {
  final CandidateModel application;
  final bool isEmployer;

  const JobApplicationDetailsView({
    super.key,
    required this.application,
    this.isEmployer = false,
  });

  @override
  State<JobApplicationDetailsView> createState() => _JobApplicationDetailsViewState();
}

class _JobApplicationDetailsViewState extends State<JobApplicationDetailsView> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(colorScheme),
                  SizedBox(height: 3.h),
                  _buildCandidateInfo(colorScheme, theme),
                  SizedBox(height: 3.h),
                  _buildJobInfo(colorScheme, theme),
                  SizedBox(height: 3.h),
                  _buildCoverLetter(colorScheme, theme),
                  SizedBox(height: 3.h),
                  _buildMatchAnalysis(colorScheme, theme),
                  SizedBox(height: 10.h), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isEmployer ? _buildEmployerActions(context, colorScheme) : null,
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 20.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 5.h),
                Hero(
                  tag: 'avatar-${widget.application.id}',
                  child: CircleAvatar(
                    radius: 10.w,
                    backgroundColor: Colors.white24,
                    backgroundImage: widget.application.avatarUrl.isNotEmpty
                        ? NetworkImage(widget.application.avatarUrl)
                        : null,
                    child: widget.application.avatarUrl.isEmpty
                        ? Icon(Icons.person, size: 12.w, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  widget.application.name,
                  style: GoogleFonts.outfit(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.application.headline,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(ColorScheme colorScheme) {
    final statusColor = widget.application.statusColor();
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Status: ${widget.application.statusDisplay}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  _getStatusDescription(_currentStatus),
                  style: TextStyle(
                    color: statusColor.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateInfo(ColorScheme colorScheme, ThemeData theme) {
    return _buildSection(
      title: 'Candidate Details',
      
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', widget.application.email),
          _buildInfoRow(Icons.phone_outlined, 'Phone', widget.application.phone.isNotEmpty ? widget.application.phone : 'Not provided'),
          _buildInfoRow(Icons.history_outlined, 'Experience', widget.application.experience.isNotEmpty ? widget.application.experience : 'Not provided'),
          _buildInfoRow(Icons.attach_money_outlined, 'Exp. Salary', widget.application.expectedSalary.isNotEmpty ? widget.application.expectedSalary : 'Not provided'),
          _buildInfoRow(Icons.schedule_outlined, 'Availability', widget.application.availability.isNotEmpty ? widget.application.availability : 'Not provided'),
          
          if (widget.application.linkedIn.isNotEmpty || widget.application.portfolio.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                if (widget.application.linkedIn.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: ActionChip(
                      onPressed: () => _launchURL(widget.application.linkedIn),
                      avatar: const Icon(Icons.link, size: 16),
                      label: Text('LinkedIn', style: TextStyle(fontSize: 9.sp)),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                if (widget.application.portfolio.isNotEmpty)
                  ActionChip(
                    onPressed: () => _launchURL(widget.application.portfolio),
                    avatar: const Icon(Icons.web, size: 16),
                    label: Text('Portfolio', style: TextStyle(fontSize: 9.sp)),
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                  ),
              ],
            ),
          ],
          if (widget.application.skills.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skills',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: widget.application.skills.map((skill) => Chip(
                label: Text(skill, style: TextStyle(fontSize: 9.sp)),
                backgroundColor: colorScheme.surfaceContainerHighest,
              )).toList(),
            ),
          ],
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _viewResume(),
              icon: const Icon(Icons.description_outlined),
              label: const Text('View Full Resume'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo(ColorScheme colorScheme, ThemeData theme) {
    return _buildSection(
      title: 'Job Applied For',
      icon: Icons.work_outline,
      child: Column(
        children: [
          _buildInfoRow(Icons.title, 'Job Title', widget.application.jobTitle),
          _buildInfoRow(Icons.business_outlined, 'Department', widget.application.jobDepartment),
          _buildInfoRow(Icons.location_on_outlined, 'Location', widget.application.jobLocation),
          _buildInfoRow(Icons.timer_outlined, 'Job Type', widget.application.jobType),
        ],
      ),
    );
  }

  Widget _buildCoverLetter(ColorScheme colorScheme, ThemeData theme) {
    return _buildSection(
      title: 'Cover Letter',
      icon: Icons.notes,
      child: Text(
        widget.application.coverLetter.isNotEmpty 
          ? widget.application.coverLetter 
          : 'No cover letter provided.',
        style: TextStyle(
          fontSize: 12.sp,
          height: 1.5,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildMatchAnalysis(ColorScheme colorScheme, ThemeData theme) {
    return _buildSection(
      title: 'AI Match Analysis',
      icon: Icons.smart_toy_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircularProgressIndicator(
                value: widget.application.matchScore / 100,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                color: _getScoreColor(widget.application.matchScore),
                strokeWidth: 8,
              ),
              SizedBox(width: 4.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.application.matchScore.toInt()}% Match',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(widget.application.matchScore),
                    ),
                  ),
                  Text(
                    'Overall Compatibility Score',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Analysis Reasoning',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
          ),
          SizedBox(height: 1.h),
          Text(
            widget.application.matchReasoning,
            style: TextStyle(
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              SizedBox(width: 2.w),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 3.w),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerActions(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 3.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showStatusPicker(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update Status'),
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.email, color: Colors.green),
              onPressed: () => _contactCandidate(),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Candidate Status', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 3.h),
            _statusOption('pending', Icons.hourglass_empty, 'New / Pending'),
            _statusOption('reviewed', Icons.visibility_outlined, 'Mark as Reviewed'),
            _statusOption('shortlisted', Icons.star_outline, 'Shortlist Candidate'),
            _statusOption('hired', Icons.verified_user_outlined, 'Hire Candidate'),
            _statusOption('rejected', Icons.close, 'Reject Application'),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(String status, IconData icon, String label) {
    // Use the model's logic for color by creating a temporary copy
    final tempColor = widget.application.copyWith(status: status).statusColor();
    return ListTile(
      leading: Icon(icon, color: tempColor),
      title: Text(label),
      trailing: _currentStatus == status ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        Navigator.pop(context);
        _updateStatus(status);
      },
    );
  }

  Future<void> _updateStatus(String status) async {
    final success = await context.read<JobApplicationProvider>().updateApplicationStatus(
      applicationId: widget.application.id,
      status: status,
    );

    if (success && mounted) {
      setState(() => _currentStatus = status);
      ErrorHandlerUI.showSuccessSnackbar(context, 'Status updated successfully');
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending': return 'Waiting for employer review.';
      case 'reviewed': return 'The employer has viewed this application.';
      case 'shortlisted': return 'Candidate has been moved to the next round.';
      case 'rejected': return 'Application did not meet the requirements.';
      case 'hired': return 'Successfully hired for this position!';
      default: return '';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _viewResume() async {
    if (widget.application.resumeUrl.isNotEmpty) {
      final url = Uri.parse(widget.application.resumeUrl);
      try {
        final success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!success && mounted) {
          ErrorHandlerUI.showErrorSnackbar(context, 'Could not open resume');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandlerUI.showErrorSnackbar(context, 'Error opening resume: $e');
        }
      }
    } else {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(context, 'No resume URL available');
      }
    }
  }

  Future<void> _contactCandidate() async {
    final url = Uri.parse('mailto:${widget.application.email}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    try {
      final url = Uri.parse(urlString);
      final success = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!success && mounted) {
        ErrorHandlerUI.showErrorSnackbar(context, 'Could not open link: $urlString');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(context, 'Error launching URL: $e');
      }
      debugPrint('Error launching URL: $e');
    }
  }
}
