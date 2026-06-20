import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/views/employer/job_details_sheet.dart';
import 'package:leox/views/employer/create_job_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  static const List<Color> _baseColors = [
    Colors.blue,
    Colors.teal,
    Colors.purple,
    Colors.amber,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.orange,
  ];

  const JobCard({super.key, required this.job});

  Color _getJobColor(JobModel job) {
    return _baseColors[job.id.hashCode.abs() % _baseColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = _getJobColor(job);
    
    // Cohesive theme colors for card borders, background, and chips
    final backgroundColor = isDark ? cardColor.withValues(alpha: 0.1) : cardColor.withValues(alpha: 0.05);
    final borderColor = cardColor.withValues(alpha: isDark ? 0.35 : 0.2);
    final elementColor = cardColor;
    final textColor = isDark ? cardColor.withValues(alpha: 0.95) : cardColor.withValues(alpha: 0.85);

    return InkWell(
      onTap: () => _openDetails(context, cardColor),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TITLE + ACTIONS =================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: elementColor,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Job"),
                            content: const Text("Are you sure you want to delete this job posting?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.read<EmployerJobsProvider>().deleteJob(job);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateJobView(jobToEdit: job),
                          ),
                        );
                      }
                    },
                    itemBuilder:
                        (_) => const [
                          PopupMenuItem(value: 'edit', child: Text("Edit")),
                          PopupMenuItem(value: 'delete', child: Text("Delete")),
                        ],
                  ),
                ],
              ),

              SizedBox(height: 0.5.h),

              // ================= META CHIPS =================
              Wrap(
                spacing: 1.5.w,
                runSpacing: 0.8.h,
                children: [
                   _chip(context, Icons.business_rounded, job.companyName.isNotEmpty ? job.companyName : "No Company", elementColor, textColor),
                   _chip(context, Icons.location_on_rounded, job.location.isNotEmpty ? job.location : "No Location", elementColor, textColor),
                   _chip(context, Icons.payments_rounded, job.salaryRange.isNotEmpty ? job.salaryRange : "No Salary", elementColor, textColor),
                   _chip(context, Icons.apartment_rounded, job.department.isNotEmpty ? job.department : "No Department", elementColor, textColor),
                   _chip(context, Icons.category_rounded, job.category.isNotEmpty ? job.category : "No Category", elementColor, textColor),
                   _chip(context, Icons.work_outline_rounded, job.jobType.isNotEmpty ? job.jobType : "No Job Type", elementColor, textColor),
                   _chip(context, Icons.psychology_rounded, job.experienceLevel.isNotEmpty ? job.experienceLevel : "No Experience", elementColor, textColor),
                   _chip(context, Icons.verified_outlined, job.status, elementColor, textColor),
                ],
              ),

              SizedBox(height: 1.5.h),

              // ================= DESCRIPTION PREVIEW =================
              Text(
                job.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.4,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                ),
              ),

              SizedBox(height: 1.5.h),

              // ================= FOOTER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Posted on ${job.postedOn.day}/${job.postedOn.month}/${job.postedOn.year}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(1.2.w),
                    decoration: BoxDecoration(
                      color: elementColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: elementColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _chip(BuildContext context, IconData icon, String text, Color baseColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: textColor),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => JobDetailsSheet(job: job, themeColor: themeColor),
    );
  }
}
