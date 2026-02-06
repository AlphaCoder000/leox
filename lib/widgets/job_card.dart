import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:sizer/sizer.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.5.h),
            Text(job.department),
            SizedBox(height: 0.5.h),
            Text("Category: ${job.category}"),
            SizedBox(height: 0.5.h),
            Text(
              "Posted on: ${job.postedOn.toLocal().toString().split(' ')[0]}",
            ),
          ],
        ),
      ),
    );
  }
}
