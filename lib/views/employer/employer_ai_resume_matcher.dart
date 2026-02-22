/// Employer AI Resume Matcher View
///
/// Allows employers to analyze resumes against job descriptions
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constants/employer_drawer_item.dart';
import '../../providers/ai_resume_matcher_provider.dart';
import '../../widgets/employer_drawer.dart';

class EmployerAiResumeMatcherView extends StatelessWidget {
  const EmployerAiResumeMatcherView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AIResumeMatcherProvider(),
      child: const _EmployerAiResumeMatcherViewBody(),
    );
  }
}

class _EmployerAiResumeMatcherViewBody extends StatefulWidget {
  const _EmployerAiResumeMatcherViewBody();

  @override
  State<_EmployerAiResumeMatcherViewBody> createState() => _EmployerAiResumeMatcherViewBodyState();
}

class _EmployerAiResumeMatcherViewBodyState extends State<_EmployerAiResumeMatcherViewBody> {
  final TextEditingController _jobDescController = TextEditingController();

  @override
  void dispose() {
    _jobDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<AIResumeMatcherProvider>();

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.aiMatcher),
      appBar: AppBar(
        title: const Text("AI Resume Matcher"),
        actions: [
          IconButton(
            onPressed: provider.clearAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear All',
          ),
        ],
      ),
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
            SizedBox(height: 0.8.h),
            Text(
              "Upload a resume and provide job description to get an instant match analysis.",
              style: TextStyle(
                fontSize: 12.5.sp,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),

            SizedBox(height: 3.h),

            // ================= INPUT DETAILS CARD =================
            _buildInputCard(context, provider),

            SizedBox(height: 3.h),

            // ================= AI MATCH ANALYSIS CARD =================
            _buildAnalysisCard(context, provider),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, AIResumeMatcherProvider provider) {
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
            Text(
              "Input Details",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.6.h),
            Text(
              "Upload a resume and provide job description to analyze.",
              style: TextStyle(
                fontSize: 11.5.sp,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 2.h),

            // Job Description
            _buildLabel(context, "Job Description"),
            SizedBox(height: 0.8.h),
            TextField(
              controller: _jobDescController,
              maxLines: 6,
              onChanged: provider.updateJobDescription,
              decoration: InputDecoration(
                hintText: "Paste full job description here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.all(3.w),
              ),
            ),

            SizedBox(height: 2.h),

            // Resume Upload
            _buildLabel(context, "Upload Resume"),
            SizedBox(height: 0.8.h),
            InkWell(
              onTap: provider.isUploading ? null : () => provider.pickResumeFile(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.6.h,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(10),
                  color: provider.isUploading ? theme.disabledColor.withValues(alpha: 0.1) : null,
                ),
                child: provider.isUploading
                    ? Column(
                        children: [
                          LinearProgressIndicator(value: provider.uploadProgress),
                          SizedBox(height: 1.h),
                          Text(
                            "Uploading... ${(provider.uploadProgress * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(Icons.upload_file_rounded),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              provider.selectedResumeFileName ?? "Choose File  •  No file chosen",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                          if (provider.selectedResumeUrl != null) ...[
                            SizedBox(width: 2.w),
                            IconButton(
                              onPressed: () {
                                // View resume in browser
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Resume viewer coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View Resume',
                            ),
                          ],
                        ],
                      ),
              ),
            ),

            SizedBox(height: 0.8.h),

            Text(
              "Supported formats: PDF, PNG, JPG, WebP. Max 5MB.",
              style: TextStyle(
                fontSize: 10.5.sp,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),

            SizedBox(height: 2.5.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isAnalyzing ? null : () => provider.parseResume(),
                    icon: const Icon(Icons.analytics),
                    label: Text(
                      provider.isAnalyzing ? "Parsing..." : "Parse Resume",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isAnalyzing ? null : () => provider.matchResumeToJob(),
                    icon: const Icon(Icons.auto_graph_rounded),
                    label: Text(
                      provider.isAnalyzing ? "Analyzing..." : "Get Match Score",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Error Message
            if (provider.errorMessage.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        provider.errorMessage,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, AIResumeMatcherProvider provider) {
    final theme = Theme.of(context);
    final results = provider.matchResults;

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
              "AI Match Analysis",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.6.h),
            Text(
              "The AI-powered analysis of match will appear here.",
              style: TextStyle(
                fontSize: 11.5.sp,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 2.h),

            if (results.isEmpty) ...[
              Container(
                height: 25.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Parsed Resume Results
              if (results['parsed'] == true) _buildParsedResults(context, results),
              
              // Match Results
              if (results['matched'] == true) _buildMatchResults(context, results),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParsedResults(BuildContext context, Map<String, dynamic> results) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confidence Score
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.verified, color: colorScheme.primary),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Resume Parsed Successfully",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      "Confidence: ${(results['confidence'] * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Skills
        if (results['skills'].isNotEmpty) ...[
          _buildLabel(context, "Skills Found"),
          SizedBox(height: 0.5.h),
          Wrap(
            spacing: 1.w,
            runSpacing: 0.5.h,
            children: (results['skills'] as List<String>)
                .take(10)
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
        ],

        SizedBox(height: 2.h),

        // Experience
        if (results['experience'].isNotEmpty) ...[
          _buildLabel(context, "Experience Found"),
          SizedBox(height: 0.5.h),
          Text(
            "${results['experience'].length} positions detected",
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMatchResults(BuildContext context, Map<String, dynamic> results) {
    final theme = Theme.of(context);
    final provider = context.watch<AIResumeMatcherProvider>();
    final overallScore = (results['overallScore'] as double?) ?? 0.0;
    final scoreColor = provider.getScoreColor(overallScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Score
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Color(int.parse(scoreColor.replaceAll('#', '0xFF'))).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Color(int.parse(scoreColor.replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.getScoreGrade(overallScore),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Overall Match Score",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      "${overallScore.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(scoreColor.replaceAll('#', '0xFF'))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Score Breakdown
        _buildScoreBreakdown(context, results),

        SizedBox(height: 2.h),

        // Matched Skills
        if (results['matchedSkills'].isNotEmpty) ...[
          _buildLabel(context, "Matched Skills"),
          SizedBox(height: 0.5.h),
          Wrap(
            spacing: 1.w,
            runSpacing: 0.5.h,
            children: (results['matchedSkills'] as List<String>)
                .map((skill) => Chip(
                      label: Text(
                        skill,
                        style: TextStyle(fontSize: 9.sp),
                      ),
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 9.sp,
                      ),
                    ))
                .toList(),
          ),
        ],

        SizedBox(height: 2.h),

        // Missing Skills
        if (results['missingSkills'].isNotEmpty) ...[
          _buildLabel(context, "Missing Skills"),
          SizedBox(height: 0.5.h),
          Wrap(
            spacing: 1.w,
            runSpacing: 0.5.h,
            children: (results['missingSkills'] as List<String>)
                .map((skill) => Chip(
                      label: Text(
                        skill,
                        style: TextStyle(fontSize: 9.sp),
                      ),
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 9.sp,
                      ),
                    ))
                .toList(),
          ),
        ],

        SizedBox(height: 2.h),

        // Analysis
        if (results['analysis'].isNotEmpty) ...[
          _buildLabel(context, "AI Analysis"),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              results['analysis'],
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],

        SizedBox(height: 2.h),

        // Recommendations
        if (results['recommendations'].isNotEmpty) ...[
          _buildLabel(context, "Recommendations"),
          SizedBox(height: 0.5.h),
          ...results['recommendations'].map<Widget>((rec) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildScoreBreakdown(BuildContext context, Map<String, dynamic> results) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Score Breakdown",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 1.h),
          _buildScoreItem("Skills Match", "${(results['skillsMatch'] as double?)?.toStringAsFixed(1) ?? '0.0'}%"),
          _buildScoreItem("Experience Match", "${(results['experienceMatch'] as double?)?.toStringAsFixed(1) ?? '0.0'}%"),
          _buildScoreItem("Education Match", "${(results['educationMatch'] as double?)?.toStringAsFixed(1) ?? '0.0'}%"),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
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
