/// Candidates View
///
/// Shows all job applications and candidates for employer
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/theme_povider.dart';
import '../../models/job_application_model.dart';
import '../../utils/error_handler_ui.dart';
import '../../constants/employer_drawer_item.dart';
import '../../widgets/employer_drawer.dart';

class CandidatesView extends StatefulWidget {
  const CandidatesView({super.key});

  @override
  State<CandidatesView> createState() => _CandidatesViewState();
}

class _CandidatesViewState extends State<CandidatesView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationProvider>().loadEmployerApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final applicationProvider = context.watch<JobApplicationProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.candidates),
      appBar: AppBar(
        title: const Text('Candidates'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // 🌗 THEME MENU
          PopupMenuButton<String>(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark 
                  ? Icons.light_mode_outlined 
                  : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
            onSelected: (value) {
              final themeProvider = context.read<ThemeProvider>();
              if (value == 'light') themeProvider.setLight();
              if (value == 'dark') themeProvider.setDark();
              if (value == 'system') themeProvider.setSystem();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'light', child: Text("Light")),
                  const PopupMenuItem(value: 'dark', child: Text("Dark")),
                  const PopupMenuItem(value: 'system', child: Text("System")),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'All (${applicationProvider.getApplicationCountByStatus('all')})',
            ),
            Tab(
              text: 'Pending (${applicationProvider.getApplicationCountByStatus('pending')})',
            ),
            Tab(
              text: 'Reviewed (${applicationProvider.getApplicationCountByStatus('reviewed')})',
            ),
            Tab(
              text: 'Shortlisted (${applicationProvider.getApplicationCountByStatus('shortlisted')})',
            ),
            Tab(
              text: 'Rejected (${applicationProvider.getApplicationCountByStatus('rejected')})',
            ),
            Tab(
              text: 'Hired (${applicationProvider.getApplicationCountByStatus('hired')})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList('all'),
          _buildApplicationsList('pending'),
          _buildApplicationsList('reviewed'),
          _buildApplicationsList('shortlisted'),
          _buildApplicationsList('rejected'),
          _buildApplicationsList('hired'),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(String status) {
    final applicationProvider = context.watch<JobApplicationProvider>();
    final applications = applicationProvider.getApplicationsByStatus(status);

    if (applicationProvider.isLoading && applications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 20.w,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
            SizedBox(height: 2.h),
            Text(
              status == 'all' 
                  ? 'No applications yet'
                  : 'No ${status.toLowerCase()} applications',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<JobApplicationProvider>().loadEmployerApplications();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(2.w),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplicationModel application) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with candidate info
            Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 5.w,
                  backgroundImage: application.employeeProfilePicture.isNotEmpty
                      ? NetworkImage(application.employeeProfilePicture)
                      : null,
                  child: application.employeeProfilePicture.isEmpty
                      ? Icon(Icons.person, size: 4.w)
                      : null,
                ),
                SizedBox(width: 3.w),
                
                // Candidate Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.employeeName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        application.employeeHeadline,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        application.employeeEmail,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Color(int.parse(application.statusColor.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.statusDisplay,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.5.h),
            
            // Job Info
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Applied for: ${application.jobTitle}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (application.jobDepartment.isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      'Department: ${application.jobDepartment}',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ],
                  if (application.jobType.isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      'Type: ${application.jobType}',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ],
                  if (application.jobLocation.isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      'Location: ${application.jobLocation}',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ],
                ],
              ),
            ),
            
            // Skills
            if (application.employeeSkills.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                'Skills:',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 0.5.h),
              Wrap(
                spacing: 1.w,
                runSpacing: 0.5.h,
                children: application.employeeSkills
                    .take(5)
                    .map((skill) => Chip(
                          label: Text(
                            skill,
                            style: TextStyle(fontSize: 9.sp),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 9.sp,
                          ),
                        ))
                    .toList(),
              ),
              if (application.employeeSkills.length > 5)
                Text(
                  '+${application.employeeSkills.length - 5} more skills',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            // Cover Letter
            if (application.coverLetter.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                'Cover Letter:',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  application.coverLetter.length > 200
                      ? '${application.coverLetter.substring(0, 200)}...'
                      : application.coverLetter,
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ],
            
            SizedBox(height: 1.5.h),
            
            // Action Buttons
            Row(
              children: [
                // View Resume Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewResume(application),
                    icon: const Icon(Icons.description, size: 16),
                    label: Text(
                      'View Resume',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      foregroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                
                // Contact Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactCandidate(application),
                    icon: const Icon(Icons.email, size: 16),
                    label: Text(
                      'Contact',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                
                // Status Update Dropdown
                Expanded(
                  child: PopupMenuButton<String>(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Update Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    onSelected: (status) => _updateApplicationStatus(application.id, status),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reviewed',
                        child: Text('Mark as Reviewed'),
                      ),
                      const PopupMenuItem(
                        value: 'shortlisted',
                        child: Text('Shortlist'),
                      ),
                      const PopupMenuItem(
                        value: 'rejected',
                        child: Text('Reject'),
                      ),
                      const PopupMenuItem(
                        value: 'hired',
                        child: Text('Mark as Hired'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewResume(JobApplicationModel application) async {
    if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty) {
      final url = Uri.parse(application.resumeUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ErrorHandlerUI.showErrorSnackbar(
            context,
            'Could not open resume',
          );
        }
      }
    } else {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          'No resume available',
        );
      }
    }
  }

  Future<void> _contactCandidate(JobApplicationModel application) async {
    final url = Uri.parse('mailto:${application.employeeEmail}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          'Could not open email app',
        );
      }
    }
  }

  Future<void> _updateApplicationStatus(String applicationId, String status) async {
    final success = await context.read<JobApplicationProvider>().updateApplicationStatus(
      applicationId: applicationId,
      status: status,
    );

    if (mounted) {
      if (success) {
        ErrorHandlerUI.showSuccessSnackbar(
          context,
          'Application status updated to $status',
        );
      } else {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          context.read<JobApplicationProvider>().errorMessage ?? 'Failed to update status',
        );
      }
    }
  }
}
