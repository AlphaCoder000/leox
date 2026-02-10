import 'package:flutter/material.dart';
import 'package:leox/views/employee/employee_profile_view.dart';
import 'package:sizer/sizer.dart';
import '../../models/job_model.dart';

class EmployeeApplyJobView extends StatelessWidget {
  final JobModel job;
  final bool hasResume; // later from provider

  const EmployeeApplyJobView({
    super.key,
    required this.job,
    this.hasResume = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Apply Job")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= JOB SUMMARY =================
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          job.status,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 0.6.h),

                  Text(
                    job.department,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  _info(
                    Icons.calendar_today_outlined,
                    "Posted",
                    "${job.postedOn.day}/${job.postedOn.month}/${job.postedOn.year}",
                  ),
                  _info(
                    Icons.verified_outlined,
                    "Status",
                    "Actively accepting applications",
                  ),

                  SizedBox(height: 1.5.h),

                  Text(
                    "Summary",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    job.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // ================= RESUME REQUIRED =================
            _card(
              context,
              borderColor: Colors.orange,
              bgColor: Colors.orange.withOpacity(0.05),
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 34.sp,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Resume Required",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    "You must upload a resume before you can apply for jobs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Why do I need a resume?",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Your resume helps employers understand your qualifications and experience. It's a required part of the application process.",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.5.h),

                  // GO TO PROFILE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmployeeProfileView(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Go to Profile to Upload Resume"),
                    ),
                  ),

                  SizedBox(height: 1.2.h),

                  // BACK
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Jobs"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _card(
    BuildContext context, {
    required Widget child,
    Color? borderColor,
    Color? bgColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor ?? theme.dividerColor),
      ),
      color: bgColor ?? theme.cardColor,
      child: Padding(padding: EdgeInsets.all(4.w), child: child),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey),
          SizedBox(width: 3.w),
          Text("$label: ", style: TextStyle(fontSize: 12.sp)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
