import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/widgets/employer_drawer.dart';
import 'package:sizer/sizer.dart';

class EmployerAiResumeMatcherView extends StatefulWidget {
  const EmployerAiResumeMatcherView({super.key});

  @override
  State<EmployerAiResumeMatcherView> createState() =>
      _EmployerAiResumeMatcherViewState();
}

class _EmployerAiResumeMatcherViewState
    extends State<EmployerAiResumeMatcherView> {
  final TextEditingController jobDescController = TextEditingController();
  String? selectedFileName;
  bool isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.aiMatcher),

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
                color: colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              "Paste a resume and job description to get an instant match analysis.",
              style: TextStyle(
                fontSize: 12.5.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 3.h),

            // ================= INPUT DETAILS CARD =================
            _sectionCard(
              context,
              title: "Input Details",
              subtitle:
                  "Upload a resume and provide the job description to analyze.",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, "Job Description"),
                  SizedBox(height: 0.8.h),

                  TextField(
                    controller: jobDescController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Paste the full job description here...",
                    ),
                  ),

                  SizedBox(height: 2.h),

                  _label(context, "Upload Resume"),
                  SizedBox(height: 0.8.h),

                  InkWell(
                    onTap: () {
                      // 🔹 TEMP (later: file_picker)
                      setState(() {
                        selectedFileName = "resume_sample.pdf";
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.6.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.upload_file_rounded),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              selectedFileName ??
                                  "Choose File  •  No file chosen",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 0.8.h),

                  Text(
                    "Supported formats: PDF, PNG, JPG, WebP. Max 5MB.",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: 2.5.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          isAnalyzing
                              ? null
                              : () {
                                setState(() {
                                  isAnalyzing = true;
                                });

                                // 🔹 TEMP simulate analysis
                                Future.delayed(const Duration(seconds: 2), () {
                                  setState(() {
                                    isAnalyzing = false;
                                  });
                                });
                              },
                      icon: const Icon(Icons.auto_graph_rounded),
                      label: Text(
                        isAnalyzing ? "Analyzing..." : "Get Match Score",
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // ================= AI MATCH ANALYSIS CARD =================
            _sectionCard(
              context,
              title: "AI Match Analysis",
              subtitle:
                  "The AI-powered analysis of the match will appear here.",
              child: Container(
                height: 25.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Results will be displayed here after analysis.",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE UI =================

  Widget _sectionCard(
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
            SizedBox(height: 0.6.h),
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

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
