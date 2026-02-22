import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/views/employer/job_details_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 4,
        shadowColor: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TITLE + ACTIONS =================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colorScheme.primary.withAlpha(38),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        context.read<EmployerJobsProvider>().deleteJob(job);
                      }
                      // Edit → next step
                    },
                    itemBuilder:
                        (_) => const [
                          PopupMenuItem(value: 'edit', child: Text("Edit")),
                          PopupMenuItem(value: 'delete', child: Text("Delete")),
                        ],
                  ),
                ],
              ),

              SizedBox(height: 1.h),

              // ================= META CHIPS =================
              Wrap(
                spacing: 2.w,
                runSpacing: 0.8.h,
                children: [
                  _chip(context, Icons.apartment_rounded, job.department),
                  _chip(context, Icons.category_rounded, job.category),
                ],
              ),

              SizedBox(height: 1.5.h),

              // ================= DESCRIPTION PREVIEW =================
              Text(
                job.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),

              SizedBox(height: 2.h),

              // ================= FOOTER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Posted on ${job.postedOn.day}/${job.postedOn.month}/${job.postedOn.year}",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: theme.textTheme.bodySmall?.color?.withAlpha(153),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(1.2.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: colorScheme.primary,
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

  Widget _chip(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: colorScheme.primary),
          SizedBox(width: 1.5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => JobDetailsSheet(job: job),
    );
  }
}
