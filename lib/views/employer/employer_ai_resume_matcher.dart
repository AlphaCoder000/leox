import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constants/employer_drawer_item.dart';
import '../../providers/ai_resume_matcher_provider.dart';
import '../../providers/employer_jobs_provider.dart';
import '../../widgets/employer_drawer.dart';
import '../../models/job_model.dart';

class EmployerAiResumeMatcherView extends StatelessWidget {
  const EmployerAiResumeMatcherView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIResumeMatcherProvider()),
        // Ensure EmployerJobsProvider is available if not already provided higher up
      ],
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
  JobModel? _selectedJob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerJobsProvider>().loadJobs();
    });
  }

  @override
  void dispose() {
    _jobDescController.dispose();
    super.dispose();
  }

  void _onJobSelected(JobModel? job, AIResumeMatcherProvider provider) {
    setState(() {
      _selectedJob = job;
      if (job != null) {
        final jobText = "Title: ${job.title}\nDescription: ${job.description}\nRequirements: ${job.requirements.join(', ')}";
        _jobDescController.text = jobText;
        provider.updateJobDescription(jobText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<AIResumeMatcherProvider>();
    final jobsProvider = context.watch<EmployerJobsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF030712), // Deeper dark background
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.aiMatcher),
      appBar: AppBar(
        title: const Text("AI Resume Matcher", style: TextStyle(fontSize: 18),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              provider.clearAll();
              _jobDescController.clear();
              setState(() => _selectedJob = null);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF030712), Color(0xFF0B1222)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(2.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= PAGE HEADER =================
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.auto_awesome, color: colorScheme.primary, size: 18.sp),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Precision Matching",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "AI-powered intelligence for your hiring pipeline",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // ================= SELECT JOB DROPDOWN =================
              _buildJobSelectionSection(jobsProvider, provider),

              SizedBox(height: 2.h),

              // ================= QUICK POPULAR ROLES =================
              _buildPopularRoles(provider),

              SizedBox(height: 2.h),

              // ================= INPUT DETAILS CARD =================
              _buildInputCard(context, provider),

              SizedBox(height: 2.h),

              // ================= AI MATCH ANALYSIS CARD =================
              _buildAnalysisCard(context, provider),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSelectionSection(EmployerJobsProvider jobsProvider, AIResumeMatcherProvider provider) {
    if (jobsProvider.jobs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Select from Your Job Postings"),
        SizedBox(height: 0.5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<JobModel>(
              value: _selectedJob,
              hint: const Text("Select a job to analyze against", style: TextStyle(color: Colors.grey)),
              isExpanded: true,
              dropdownColor: const Color(0xFF111827),
              items: jobsProvider.jobs.map((job) {
                return DropdownMenuItem(
                  value: job,
                  child: Text(job.title, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (job) => _onJobSelected(job, provider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context, AIResumeMatcherProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2937)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: colorScheme.primary, size: 17.sp),
              SizedBox(width: 3.w),
              Text(
                "Assessment Input",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Job Description
          _buildLabel(context, "Target Description"),
          SizedBox(height: 0.5.h),
          TextField(
            controller: _jobDescController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: provider.updateJobDescription,
            decoration: InputDecoration(
              hintText: "Enter the skills and responsibilities you're looking for...",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: const Color(0xFF030712),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // Resume Upload
          _buildLabel(context, "Candidate Portfolio (PDF/Text)"),
          SizedBox(height: 0.5.h),
          InkWell(
            onTap: provider.isUploading ? null : () => provider.pickResumeFile(),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: provider.selectedResumeFileName != null 
                    ? colorScheme.primary.withValues(alpha: 0.5) 
                    : Colors.white.withValues(alpha: 0.1),
                  style: provider.selectedResumeFileName != null ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
              child: provider.isUploading
                  ? Column(
                      children: [
                        LinearProgressIndicator(
                          value: provider.uploadProgress,
                          backgroundColor: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Ingesting Data... ${(provider.uploadProgress * 100).toInt()}%",
                          style: TextStyle(fontSize: 16.sp, color: colorScheme.primary),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          provider.selectedResumeFileName != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                          color: provider.selectedResumeFileName != null ? Colors.greenAccent : colorScheme.primary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            provider.selectedResumeFileName ?? "Tap here to Select Resume Document",
                            style: TextStyle(
                              fontSize: 16.sp, 
                              color: provider.selectedResumeFileName != null ? Colors.white : Colors.white54
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.selectedResumeFileName != null)
                          const Icon(Icons.edit_outlined, size: 18, color: Colors.white38),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Main Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isAnalyzing || provider.isUploading 
                ? null 
                : () => provider.matchResumeToJob(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: provider.isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withValues(alpha: 0.8))),
                      SizedBox(width: 3.w),
                      const Text("Synthesizing Match Data..."),
                    ],
                  )
                : const Text("Perform AI Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),

          // Error Message
          if (provider.errorMessage.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(provider.errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, AIResumeMatcherProvider provider) {
    if (provider.matchResults.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          children: [
            Icon(Icons.insights, size: 40.sp, color: Colors.white.withValues(alpha: 0.1)),
            SizedBox(height: 2.h),
            Text(
              "Analytics Pending",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            SizedBox(height: 1.h),
            Text(
              "Results will appear here after analysis",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 15.sp),
            ),
          ],
        ),
      );
    }

    final results = provider.matchResults;
    final overallScore = (results['overallScore'] as num?)?.toDouble() ?? 0.0;
    final scoreColor = Color(int.parse(provider.getScoreColor(overallScore).replaceAll('#', '0xFF')));

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Expert Analysis", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              _buildGradeBadge(provider.getScoreGrade(overallScore), scoreColor),
            ],
          ),
          SizedBox(height: 4.h),

          // Match Percentage Visual
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: overallScore / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        color: scoreColor,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${overallScore.toInt()}%",
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text("Match", style: TextStyle(fontSize: 16.sp, color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Analysis Summary
          if (results['analysis'] != null) ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                results['analysis'],
                style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 16),
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Stats Grid
          _buildStatsRow(results),

          SizedBox(height: 4.h),

          // Strengths & Gaps
          if (results['strengths'] != null && results['strengths'].isNotEmpty)
            _buildResultList("Key Match Points", results['strengths'], Colors.greenAccent),
          
          if (results['gaps'] != null && results['gaps'].isNotEmpty)
            _buildResultList("Development Areas", results['gaps'], Colors.orangeAccent),

          if (results['recommendations'] != null && results['recommendations'].isNotEmpty)
            _buildResultList("Next Steps", results['recommendations'], Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildGradeBadge(String grade, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        grade,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.sp),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> results) {
    return Row(
      children: [
        Expanded(child: _buildMiniStat("Skills", results['skillsMatch'])),
        SizedBox(width: 3.w),
        Expanded(child: _buildMiniStat("Experience", results['experienceMatch'])),
        SizedBox(width: 3.w),
        Expanded(child: _buildMiniStat("Education", results['educationMatch'])),
      ],
    );
  }

  Widget _buildMiniStat(String label, dynamic score) {
    final s = (score as num?)?.toDouble() ?? 0.0;
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text("${s.toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildResultList(String title, dynamic items, Color color) {
    final list = items as List;
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 1.5.h),
          ...list.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: color.withValues(alpha: 0.5)),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(item.toString(), style: const TextStyle(color: Colors.white60, fontSize: 16, height: 1.3)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPopularRoles(AIResumeMatcherProvider provider) {
    final roles = [
      {'title': 'Data Science',  'desc': 'Analyze complex data sets to derive insights, build ML models, and optimize business strategies. Requirements: Python, SQL, Statistics, Machine Learning frameworks.'},
      {'title': 'Machine Learning', 'desc': 'Design and implement ML algorithms/pipelines. Requirements: PyTorch/TensorFlow, Linear Algebra, Feature Engineering.'},
      {'title': 'Full Stack Dev', 'desc': 'Build end-to-end web applications. Requirements: React/Flutter, Node.js, PostgreSQL/Firebase, System Design.'},
      {'title': 'UI/UX Design', 'desc': 'Create user-centered designs and prototypes. Requirements: Figma, User Research, Wireframing, Visual Design.'},
      {'title': 'Cloud Engineer', 'desc': 'Manage cloud infrastructure and deployments. Requirements: AWS/Azure, Docker, Kubernetes, CI/CD.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Quick Roles"),
        SizedBox(height: 0.5.h),
        SizedBox(
          height: 5.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              final isSelected = _jobDescController.text.contains(role['title']!);
              return Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: ChoiceChip(
                  label: Text(role['title']!),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      final jobText = "Title: ${role['title']}\nDescription: ${role['desc']}";
                      _jobDescController.text = jobText;
                      provider.updateJobDescription(jobText);
                      setState(() => _selectedJob = null);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white24,
        letterSpacing: 1.5,
      ),
    );
  }
}

