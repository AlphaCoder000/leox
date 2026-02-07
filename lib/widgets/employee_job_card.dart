import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/job_model.dart';

class EmployeeJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onView;

  const EmployeeJobCard({super.key, required this.job, required this.onView});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            // TITLE + STATUS
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _statusChip(job.status),
              ],
            ),

            SizedBox(height: 0.6.h),

            Text(
              job.department,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 1.2.h),

            Text(
              "Posted on ${job.postedOn.day}/${job.postedOn.month}/${job.postedOn.year}",
              style: TextStyle(fontSize: 11.sp),
            ),

            SizedBox(height: 1.6.h),

            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onView,
                child: const Text("View"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isOpen = status.toLowerCase() == "open";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: isOpen ? Colors.blue.withOpacity(0.1) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w600,
          color: isOpen ? Colors.blue : Colors.black54,
        ),
      ),
    );
  }
}
