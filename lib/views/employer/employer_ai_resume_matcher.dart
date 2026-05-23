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

  // Reactive Theme Getters
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _scaffoldBg => _isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC);
  Color get _cardBg => _isDark ? const Color(0xFF111827) : Colors.white;
  Color get _innerBg => _isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9);
  Color get _borderCol => _isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
  Color get _textPrimary => _isDark ? Colors.white : const Color(0xFF0F172A);
  Color get _textSecondary => _isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF475569);
  Color get _textLabel => _isDark ? Colors.white24 : const Color(0xFF94A3B8);
  List<Color> get _gradientColors => _isDark 
      ? [const Color(0xFF030712), const Color(0xFF0B1222)] 
      : [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6)];

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
      backgroundColor: _scaffoldBg,
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.aiMatcher),
      appBar: AppBar(
        title: Text(
          "AI Resume Matcher", 
          style: TextStyle(
            fontSize: 18, 
            color: _textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _textPrimary),
        actions: [
          IconButton(
            onPressed: () {
              provider.clearAll();
              _jobDescController.clear();
              setState(() => _selectedJob = null);
            },
            icon: Icon(Icons.refresh, color: _textPrimary),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradientColors,
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
                            color: _textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "AI-powered intelligence for your hiring pipeline",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: _textSecondary,
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
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderCol),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<JobModel>(
              value: _selectedJob,
              hint: Text("Select a job to analyze against", style: TextStyle(color: _isDark ? Colors.grey : Colors.grey[600])),
              isExpanded: true,
              dropdownColor: _cardBg,
              items: jobsProvider.jobs.map((job) {
                return DropdownMenuItem(
                  value: job,
                  child: Text(job.title, style: TextStyle(color: _textPrimary)),
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
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.insights_rounded, color: colorScheme.primary, size: 16.sp),
              ),
              SizedBox(width: 3.w),
              Text(
                "Match Parameters",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _textPrimary),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Job Description
          _buildLabel(context, "Target Job Description"),
          SizedBox(height: 1.h),
          TextField(
            controller: _jobDescController,
            maxLines: 6,
            style: TextStyle(color: _textPrimary, fontSize: 13.sp),
            onChanged: provider.updateJobDescription,
            decoration: InputDecoration(
              hintText: "State the duties, required qualifications, and tools...",
              hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.4)),
              filled: true,
              fillColor: _innerBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: _borderCol),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: _borderCol),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: 2.5.h),

          // Resume Upload
          _buildLabel(context, "Candidate Portfolio (PDF / Text)"),
          SizedBox(height: 1.h),
          InkWell(
            onTap: provider.isUploading ? null : () => provider.pickResumeFile(),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
              decoration: BoxDecoration(
                color: provider.selectedResumeFileName != null 
                  ? (_isDark ? const Color(0xFF132F27) : const Color(0xFFECFDF5))
                  : _innerBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.selectedResumeFileName != null
                      ? Colors.greenAccent
                      : _borderCol,
                  width: 1.5,
                ),
                boxShadow: provider.selectedResumeFileName != null
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: _isDark ? 0.15 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: provider.isUploading
                  ? Column(
                      children: [
                        LinearProgressIndicator(
                          value: provider.uploadProgress,
                          backgroundColor: _isDark ? Colors.white10 : Colors.black12,
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          "Uploading Document... ${(provider.uploadProgress * 100).toInt()}%",
                          style: TextStyle(fontSize: 14.sp, color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : provider.selectedResumeFileName != null
                      ? Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.5.w),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Resume Loaded Successfully",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    provider.selectedResumeFileName!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: _textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.change_circle_outlined, color: colorScheme.primary, size: 20.sp),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, color: colorScheme.primary, size: 22.sp),
                            SizedBox(width: 4.w),
                            Text(
                              "Click to Select Resume File",
                              style: TextStyle(
                                fontSize: 15.sp, 
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
            ),
          ),

          SizedBox(height: 3.h),

          // Main Action
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: provider.isAnalyzing || provider.isUploading 
                ? null 
                : () => provider.matchResumeToJob(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 2.2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: provider.isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "Analyzing Alignment...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "Launch AI Match Analysis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
            ),
          ),

          // Error Message
          if (provider.errorMessage.isNotEmpty) ...[
            SizedBox(height: 2.5.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
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
          color: _cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderCol),
        ),
        child: Column(
          children: [
            Icon(Icons.insights, size: 40.sp, color: _textLabel),
            SizedBox(height: 2.h),
            Text(
              "Analytics Pending",
              style: TextStyle(color: _textPrimary.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            SizedBox(height: 1.h),
            Text(
              "Results will appear here after analysis",
              style: TextStyle(color: _textSecondary.withValues(alpha: 0.4), fontSize: 15.sp),
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
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Expert Analysis", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _textPrimary)),
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
                        backgroundColor: _isDark ? Colors.white10 : Colors.black12,
                        color: scoreColor,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${overallScore.toInt()}%",
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: _textPrimary),
                        ),
                        Text("Match", style: TextStyle(fontSize: 16.sp, color: _textSecondary)),
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
                color: _innerBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                results['analysis'],
                style: TextStyle(color: _textSecondary, height: 1.5, fontSize: 16),
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Stats Grid
          _buildStatsRow(results),

          SizedBox(height: 4.h),

          // Strengths & Gaps
          if (results['strengths'] != null && results['strengths'].isNotEmpty)
            _buildResultList("Key Match Points", results['strengths'], Colors.green),
          
          if (results['gaps'] != null && results['gaps'].isNotEmpty)
            _buildResultList("Development Areas", results['gaps'], Colors.orange),

          if (results['recommendations'] != null && results['recommendations'].isNotEmpty)
            _buildResultList("Next Steps", results['recommendations'], Colors.blue),
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
        color: _innerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text("${s.toInt()}%", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: _textSecondary, fontSize: 14)),
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
                      child: Text(item.toString(), style: TextStyle(color: _textSecondary, fontSize: 16, height: 1.3)),
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
      {
        'title': 'Mechanical Design',
        'desc': 'Design and develop mechanical components and systems. Create detailed 3D CAD models and perform finite element analysis (FEA). Requirements: SolidWorks/AutoCAD, FEA, GD&T, and Materials Science.'
      },
      {
        'title': 'HVAC Engineer',
        'desc': 'Design, analyze, and optimize heating, ventilation, and air conditioning systems. Perform thermal load calculations and airflow simulations. Requirements: ASHRAE standards, Revit MEP, thermodynamics.'
      },
      {
        'title': 'Robotics & Automation',
        'desc': 'Design robotic mechanisms, automated systems, and control integration. Oversee kinematic modeling and sensor integration. Requirements: PLC programming, ROS, actuator design, control systems.'
      },
      {
        'title': 'Manufacturing Eng',
        'desc': 'Optimize production systems, design assembly tooling, and implement Lean/Six Sigma principles to enhance manufacturing efficiency. Requirements: CNC machining, quality control, assembly lines.'
      },
      {
        'title': 'Automotive Engineer',
        'desc': 'Develop automotive structures, powertrains, and aerodynamics. Conduct structural analysis, NVH testing, and thermal management studies. Requirements: Vehicle dynamics, Matlab/Simulink, CFD.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Quick Roles"),
        SizedBox(height: 1.h),
        SizedBox(
          height: 6.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              final isSelected = _jobDescController.text.contains(role['title']!);
              return Padding(
                padding: EdgeInsets.only(right: 3.w, bottom: 2),
                child: GestureDetector(
                  onTap: () {
                    final jobText = "Title: ${role['title']}\nDescription: ${role['desc']}";
                    _jobDescController.text = jobText;
                    provider.updateJobDescription(jobText);
                    setState(() => _selectedJob = null);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : _cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : _borderCol,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        role['title']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _textSecondary,
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
        color: _textLabel,
        letterSpacing: 1.5,
      ),
    );
  }
}
