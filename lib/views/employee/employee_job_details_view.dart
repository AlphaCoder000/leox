import 'package:flutter/material.dart';
import 'package:leox/views/employee/employee_apply_job_view.dart';
import 'package:sizer/sizer.dart';
import '../../models/job_model.dart';

class EmployeeJobDetailsView extends StatelessWidget {
  final JobModel job;

  const EmployeeJobDetailsView({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Text(
              job.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              job.department,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 3.h),

            // ================= JOB DESCRIPTION =================
            _sectionCard(
              context,
              title: "Job Description",
              child: Text(
                job.description,
                style: TextStyle(fontSize: 12.8.sp, height: 1.5),
              ),
            ),

            SizedBox(height: 2.5.h),

            // ================= REQUIREMENTS =================
            _sectionCard(
              context,
              title: "Requirements",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    job.requirements
                        .map(
                          (r) => Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• "),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: TextStyle(fontSize: 12.8.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

            SizedBox(height: 2.5.h),

            // ================= JOB DETAILS =================
            _sectionCard(
              context,
              title: "Job Details",
              child: Column(
                children: [
                  _infoRow(
                    context,
                    Icons.work_outline,
                    "Department",
                    job.department,
                  ),
                  _infoRow(
                    context,
                    Icons.category_outlined,
                    "Category",
                    job.category,
                  ),
                  _infoRow(
                    context,
                    Icons.calendar_today_outlined,
                    "Posted On",
                    "${job.postedOn.day}/${job.postedOn.month}/${job.postedOn.year}",
                  ),
                  _infoRow(
                    context,
                    Icons.person_outline,
                    "Posted By",
                    job.postedBy,
                  ),
                  _infoRow(
                    context,
                    Icons.verified_outlined,
                    "Status",
                    job.status,
                    valueColor:
                        job.status == "Open" ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // ================= APPLY BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeApplyJobView(job: job),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Apply Now",
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE UI =================

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 1.5.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey),
          SizedBox(width: 3.w),
          Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
