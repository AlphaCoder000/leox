import 'package:flutter/material.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:sizer/sizer.dart';

class EmployeeAiResumeMatcherView extends StatelessWidget {
  const EmployeeAiResumeMatcherView({super.key});
  //demo writeup
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.aiMatcher),
      appBar: AppBar(title: const Text("AI Resume Matcher")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PAGE HEADER =================
            Text(
              "AI Resume Matcher",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              "Paste a resume and job description to get an instant match analysis.",
              style: TextStyle(
                fontSize: 12.5.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
              ),
            ),

            SizedBox(height: 3.h),

            // ================= INPUT DETAILS =================
            _card(
              context,
              title: "Input Details",
              subtitle:
                  "Upload a resume and provide the job description to analyze.",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Job Description"),
                  SizedBox(height: 0.8.h),
                  TextField(
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Paste the full job description here...",
                    ),
                  ),

                  SizedBox(height: 2.5.h),

                  _label("Upload Resume"),
                  SizedBox(height: 0.8.h),

                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: file picker
                    },
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text("Choose File"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 1.6.h,
                        horizontal: 4.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 0.8.h),

                  Text(
                    "Supported formats: PDF, PNG, JPG, WebP. Max 5MB.",
                    style: TextStyle(
                      fontSize: 10.8.sp,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: AI API call
                      },
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text("Get Match Score"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // ================= AI MATCH ANALYSIS =================
            _card(
              context,
              title: "AI Match Analysis",
              subtitle:
                  "The AI-powered analysis of the match will appear here.",
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 42.sp,
                      color: theme.disabledColor,
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      "Results will be displayed here after analysis.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE CARD =================
  Widget _card(
    BuildContext context, {
    required String title,
    required String subtitle,
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
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 2.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
    );
  }
}
