import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:sizer/sizer.dart';

class JobDetailsSheet extends StatelessWidget {
  final JobModel job;

  const JobDetailsSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            children: [
              // 🔹 DRAG HANDLE
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.6.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // 🔹 JOB TITLE
              Text(
                job.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              SizedBox(height: 1.h),

              // 🔹 META CHIPS
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  _chip(context, Icons.apartment_rounded, job.department),
                  _chip(context, Icons.category_rounded, job.category),
                ],
              ),

              SizedBox(height: 3.h),

              // 🔹 DESCRIPTION
              _sectionCard(
                context,
                title: "Job Description",
                child: Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              // 🔹 REQUIREMENTS
              _sectionCard(
                context,
                title: "Requirements",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      job.requirements.map((req) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 1.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16.sp,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  req,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    height: 1.4,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        );
      },
    );
  }

  // ================= HELPERS =================

  Widget _chip(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: colorScheme.primary),
          SizedBox(width: 1.5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.5.h),
          child,
        ],
      ),
    );
  }
}
