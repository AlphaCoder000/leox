/// My Applications View
///
/// Shows all job applications submitted by the current employee
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/job_application_provider.dart';
import '../../models/job_application_model.dart';
import '../../utils/error_handler_ui.dart';

class MyApplicationsView extends StatefulWidget {
  const MyApplicationsView({super.key});

  @override
  State<MyApplicationsView> createState() => _MyApplicationsViewState();
}

class _MyApplicationsViewState extends State<MyApplicationsView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationProvider>().loadEmployeeApplications();
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
    final applicationProvider = context.watch<JobApplicationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
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
              Icons.work_outline,
              size: 20.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              status == 'all' 
                  ? 'No applications yet'
                  : 'No ${status.toLowerCase()} applications',
              style: TextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Start applying for jobs to see them here',
              style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<JobApplicationProvider>().loadEmployeeApplications();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with job title and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle,
                        style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        application.companyName,
                        style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: application.statusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.statusDisplay,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.5.h),
            
            // Job Details
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (application.jobDepartment.isNotEmpty) ...[
                    Text(
                      'Department: ${application.jobDepartment}',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold,),
                    ),
                  ],
                  if (application.jobType.isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      'Type: ${application.jobType}',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold,),
                    ),
                  ],
                  if (application.jobLocation.isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      'Location: ${application.jobLocation}',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold,),
                    ),
                  ],
                  if (application.salary.isNotEmpty) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      'Salary: \$${application.salary}',
                      style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Applied Date
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 3.w, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  'Applied on ${application.appliedAt.day}/${application.appliedAt.month}/${application.appliedAt.year}',
                  style: TextStyle(
                    fontSize: 12.sp, fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Cover Letter Preview
            if (application.coverLetter.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                'Cover Letter:',
                style: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  application.coverLetter.length > 150
                      ? '${application.coverLetter.substring(0, 150)}...'
                      : application.coverLetter,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold,),
                ),
              ),
            ],
            
            // Resume Info
            if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 3.w, color: colorScheme.primary),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      'Resume: ${application.resumeName ?? 'No resume'}',
                      style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
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
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      foregroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                
                // Delete Application Button (only for pending applications)
                if (application.status == 'pending')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteApplication(application),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(
                        'Withdraw',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
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

  Future<void> _deleteApplication(JobApplicationModel application) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: Text(
          'Are you sure you want to withdraw your application for ${application.jobTitle}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<JobApplicationProvider>().deleteApplication(application.id);

      if (success && mounted) {
        ErrorHandlerUI.showSuccessSnackbar(
          context,
          'Application deleted successfully!',
        );
      } else if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          context.read<JobApplicationProvider>().errorMessage ?? 'Failed to withdraw application',
        );
      }
    }
  }
}
