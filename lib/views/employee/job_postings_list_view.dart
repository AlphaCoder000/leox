/// Job Postings List View
///
/// Shows all available job postings for employees
library;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../models/job_posting_model.dart';
import '../../views/employee/job_application_view.dart';
import '../../utils/error_handler_ui.dart';

class JobPostingsListView extends StatefulWidget {
  const JobPostingsListView({super.key});

  @override
  State<JobPostingsListView> createState() => _JobPostingsListViewState();
}

class _JobPostingsListViewState extends State<JobPostingsListView> {
  List<JobPostingModel> _jobPostings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJobPostings();
  }

  Future<void> _loadJobPostings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual job postings loading from Firebase
      // For now, using mock data
      _jobPostings = [
        JobPostingModel(
          id: '1',
          title: 'Senior Flutter Developer',
          department: 'Engineering',
          description: 'We are looking for an experienced Flutter developer to join our team.',
          employerId: 'employer1',
          companyName: 'Tech Corp',
          location: 'San Francisco, CA',
          jobType: 'full-time',
          experienceLevel: 'senior',
          salary: '120,000 - 150,000',
          requirements: ['5+ years Flutter experience', 'B.S. in Computer Science'],
          skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
          benefits: ['Health Insurance', '401k', 'Remote Work'],
          postedAt: DateTime.now().subtract(const Duration(days: 3)),
          applicationCount: 12,
        ),
        JobPostingModel(
          id: '2',
          title: 'UI/UX Designer',
          department: 'Design',
          description: 'Creative UI/UX designer needed for mobile app design.',
          employerId: 'employer2',
          companyName: 'Design Studio',
          location: 'New York, NY',
          jobType: 'contract',
          experienceLevel: 'mid',
          salary: '80,000 - 100,000',
          requirements: ['3+ years design experience', 'Portfolio required'],
          skills: ['Figma', 'Sketch', 'Adobe XD', 'Prototyping'],
          benefits: ['Flexible Hours', 'Creative Environment'],
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
          applicationCount: 8,
        ),
      ];
    } catch (e) {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          'Failed to load job postings: ${e.toString()}',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Postings'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobPostings.isEmpty
              ? _buildEmptyState()
              : _buildJobPostingsList(),
    );
  }

  Widget _buildEmptyState() {
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
            'No job postings available',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Check back later for new opportunities',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobPostingsList() {
    return RefreshIndicator(
      onRefresh: _loadJobPostings,
      child: ListView.builder(
        padding: EdgeInsets.all(2.w),
        itemCount: _jobPostings.length,
        itemBuilder: (context, index) {
          final job = _jobPostings[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(JobPostingModel job) {
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
            // Header with title and company
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 12.sp,
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
                    color: job.isAcceptingApplications 
                        ? Colors.green 
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.statusDisplay,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            // Job Details
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 3.w, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  job.location,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 3.w),
                
                Icon(Icons.work_outline, size: 3.w, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  job.jobTypeDisplay,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 3.w),
                
                Icon(Icons.trending_up, size: 3.w, color: Colors.grey[600]),
                SizedBox(width: 1.w),
                Text(
                  job.experienceLevelDisplay,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            // Salary
            Row(
              children: [
                Icon(Icons.attach_money, size: 3.w, color: colorScheme.primary),
                SizedBox(width: 1.w),
                Text(
                  job.salary,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            // Description
            if (job.description.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                job.description.length > 150
                    ? '${job.description.substring(0, 150)}...'
                    : job.description,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
            
            // Skills
            if (job.skills.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Wrap(
                spacing: 1.w,
                runSpacing: 0.5.h,
                children: job.skills
                    .take(4)
                    .map((skill) => Chip(
                          label: Text(
                            skill,
                            style: TextStyle(fontSize: 9.sp),
                          ),
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 9.sp,
                          ),
                        ))
                    .toList(),
              ),
              if (job.skills.length > 4)
                Text(
                  '+${job.skills.length - 4} more skills',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            SizedBox(height: 1.5.h),
            
            // Footer with apply button and stats
            Row(
              children: [
                // Application count
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 3.w, color: Colors.grey[600]),
                      SizedBox(width: 0.5.w),
                      Text(
                        '${job.applicationCount} applicants',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Posted time
                Text(
                  '${job.daysSincePosting}d ago',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(width: 2.w),
                
                // Apply Button
                ElevatedButton(
                  onPressed: job.isAcceptingApplications
                      ? () => _navigateToApplication(job)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    job.isAcceptingApplications ? 'Apply Now' : 'Closed',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
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

  void _navigateToApplication(JobPostingModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobApplicationView(job: job),
      ),
    );
  }
}
