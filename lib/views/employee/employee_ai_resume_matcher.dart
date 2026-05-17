import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/ai_resume_matcher_provider.dart';
import '../../providers/job_application_provider.dart';
import '../../widgets/employee_drawer.dart';
import '../../models/job_application_model.dart';

class EmployeeAiResumeMatcherView extends StatelessWidget {
  const EmployeeAiResumeMatcherView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIResumeMatcherProvider()),
      ],
      child: const _EmployeeAiResumeMatcherViewBody(),
    );
  }
}

class _EmployeeAiResumeMatcherViewBody extends StatefulWidget {
  const _EmployeeAiResumeMatcherViewBody();

  @override
  State<_EmployeeAiResumeMatcherViewBody> createState() => _EmployeeAiResumeMatcherViewBodyState();
}

class _EmployeeAiResumeMatcherViewBodyState extends State<_EmployeeAiResumeMatcherViewBody> {
  final TextEditingController _jobDescController = TextEditingController();
  final TextEditingController _resumeTextController = TextEditingController();
  JobApplicationModel? _selectedApplication;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationProvider>().loadEmployeeApplications();
    });
  }

  @override
  void dispose() {
    _jobDescController.dispose();
    _resumeTextController.dispose();
    super.dispose();
  }

  void _onApplicationSelected(JobApplicationModel? app, AIResumeMatcherProvider provider) {
    setState(() {
      _selectedApplication = app;
      if (app != null) {
        final jobText = "Title: ${app.jobTitle}\nCompany: ${app.companyName}\nDescription: ${app.jobDepartment} Role";
        _jobDescController.text = jobText;
        provider.updateJobDescription(jobText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AIResumeMatcherProvider>();
    final appsProvider = context.watch<JobApplicationProvider>();

    // Premium adaptive colors
    final scaffoldBg = isDark ? const Color(0xFF030712) : theme.scaffoldBackgroundColor;
    final bgGradientColors = isDark 
        ? [const Color(0xFF030712), const Color(0xFF0F172A)]
        : [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor];
        
    final appBarTitleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final appBarIconColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    
    final cardBg = isDark ? const Color(0xFF1E293B) : theme.cardTheme.color ?? Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : theme.dividerColor;
    final dropdownBg = isDark ? const Color(0xFF1E293B) : theme.cardTheme.color ?? Colors.white;
    
    final primaryTextColor = isDark ? Colors.white : theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: scaffoldBg,
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.aiMatcher),
      appBar: AppBar(
        title: Text("Career Intelligence", style: TextStyle(color: appBarTitleColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarIconColor),
        actions: [
          IconButton(
            onPressed: () {
              provider.clearAll();
              _jobDescController.clear();
              _resumeTextController.clear();
              setState(() => _selectedApplication = null);
            },
            icon: Icon(Icons.refresh, color: appBarIconColor),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradientColors,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= PAGE HEADER =================
              _buildHeader(context),

              SizedBox(height: 4.h),

              // ================= SELECT APPLICATION =================
              if (appsProvider.applications.isNotEmpty) ...[
                _buildLabel(context, "Analyze an Existing Application"),
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: borderCol),
                    boxShadow: !isDark ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<JobApplicationModel>(
                      value: _selectedApplication,
                      hint: Text("Choose an application", style: TextStyle(color: isDark ? Colors.grey : theme.hintColor)),
                      isExpanded: true,
                      dropdownColor: dropdownBg,
                      iconEnabledColor: primaryTextColor,
                      items: appsProvider.applications.map((app) {
                        return DropdownMenuItem(
                          value: app,
                          child: Text(app.jobTitle, style: TextStyle(color: primaryTextColor, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (app) => _onApplicationSelected(app, provider),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
              ],

              // ================= QUICK TARGET ROLES =================
              _buildPopularTargetRoles(context, provider),

              SizedBox(height: 3.h),

              // ================= INPUT OPTIONS CARD =================
              _buildInputCard(context, provider),

              SizedBox(height: 3.h),

              // ================= AI MATCH ANALYSIS CARD =================
              _buildAnalysisResult(context, provider),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.indigoAccent),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Optimize Your Fit",
                style: TextStyle(
                  fontSize: 20.sp, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                "Let AI review your resume against any role",
                style: TextStyle(
                  fontSize: 13.sp, 
                  fontWeight: FontWeight.w600, 
                  color: isDark ? Colors.white54 : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context, AIResumeMatcherProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardBg = isDark ? const Color(0xFF1E293B) : theme.cardTheme.color ?? Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : theme.dividerColor;
    
    final primaryTextColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final resumeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final resumeTextColor = provider.selectedResumeFileName != null 
        ? primaryTextColor 
        : (isDark ? Colors.white38 : theme.colorScheme.onSurface.withValues(alpha: 0.45));
    final iconColor = provider.selectedResumeFileName != null 
        ? Colors.indigoAccent 
        : (isDark ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.3));

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Colors.indigoAccent),
              SizedBox(width: 2.w),
              Text(
                "Analysis Scope", 
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          _buildLabel(context, "Target Job Description"),
          SizedBox(height: 1.2.h),
          TextField(
            controller: _jobDescController,
            maxLines: 4,
            style: TextStyle(color: primaryTextColor, fontSize: 13),
            onChanged: provider.updateJobDescription,
            decoration: _inputDecoration(context, "Paste the requirements of the job you want..."),
          ),

          SizedBox(height: 3.h),

          _buildLabel(context, "Your Resume"),
          SizedBox(height: 1.2.h),
          
          InkWell(
            onTap: provider.isUploading ? null : () => provider.pickResumeFile(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: resumeBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: provider.selectedResumeFileName != null ? Colors.indigoAccent : Colors.transparent,
                ),
              ),
              child: provider.isUploading
                ? LinearProgressIndicator(value: provider.uploadProgress, backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1))
                : Row(
                    children: [
                      Icon(
                        provider.selectedResumeFileName != null ? Icons.file_present_rounded : Icons.upload_rounded,
                        color: iconColor,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          provider.selectedResumeFileName ?? "Upload PDF or Text Resume",
                          style: TextStyle(color: resumeTextColor),
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          SizedBox(height: 4.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isAnalyzing ? null : () => provider.matchResumeToJob(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: provider.isAnalyzing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 15),
                      Text("Processing Analysis..."),
                    ],
                  )
                : const Text("Generate Match Score", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          if (provider.errorMessage.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(provider.errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(BuildContext context, AIResumeMatcherProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardBg = isDark ? const Color(0xFF1E293B) : theme.cardTheme.color ?? Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : theme.dividerColor;
    final primaryTextColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final secondaryTextColor = isDark ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.7);

    if (provider.matchResults.isEmpty) {
      return Container(
        height: 20.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderCol),
        ),
        child: Center(
          child: Text(
            "AI results will appear here", 
            style: TextStyle(
              color: isDark ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.35), 
              fontSize: 13.sp, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final results = provider.matchResults;
    final overallScore = (results['overallScore'] as num?)?.toDouble() ?? 0.0;
    final scoreColor = Color(int.parse(provider.getScoreColor(overallScore).replaceAll('#', '0xFF')));

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Match report", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryTextColor)),
              _buildGradeBadge(provider.getScoreGrade(overallScore), scoreColor),
            ],
          ),
          SizedBox(height: 4.h),

          _buildMatchCircle(context, overallScore, scoreColor),

          SizedBox(height: 4.h),

          if (results['analysis'] != null) ...[
            Text("SUMMARY", style: _sectionTitleStyle(context)),
            SizedBox(height: 1.h),
            Text(results['analysis'], style: TextStyle(color: secondaryTextColor, fontSize: 13, height: 1.5)),
            SizedBox(height: 3.h),
          ],

          _buildBreakdown(context, results),

          SizedBox(height: 4.h),

          if (results['strengths'] != null) _buildPointList(context, "STRENGTHS", results['strengths'], isDark ? Colors.greenAccent : const Color(0xFF059669)),
          if (results['gaps'] != null) _buildPointList(context, "GAPS", results['gaps'], isDark ? Colors.orangeAccent : const Color(0xFFD97706)),
          if (results['recommendations'] != null) _buildPointList(context, "RECOMMENDATIONS", results['recommendations'], isDark ? Colors.indigoAccent : const Color(0xFF4F46E5)),
        ],
      ),
    );
  }

  Widget _buildMatchCircle(BuildContext context, double score, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
              color: color,
            ),
          ),
          Text(
            "${score.toInt()}%", 
            style: TextStyle(
              fontSize: 22.sp, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(BuildContext context, Map<String, dynamic> results) {
    return Row(
      children: [
        Expanded(child: _miniStep(context, "Skills", results['skillsMatch'])),
        Expanded(child: _miniStep(context, "Exp", results['experienceMatch'])),
        Expanded(child: _miniStep(context, "Edu", results['educationMatch'])),
      ],
    );
  }

  Widget _miniStep(BuildContext context, String label, dynamic score) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = (score as num?)?.toDouble() ?? 0.0;
    
    return Column(
      children: [
        Text(
          "${s.toInt()}%", 
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface, 
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label, 
          style: TextStyle(
            color: isDark ? Colors.white38 : theme.colorScheme.onSurface.withValues(alpha: 0.45), 
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPointList(BuildContext context, String title, dynamic items, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final list = items as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: TextStyle(
            color: color, 
            fontSize: 12.sp, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 1.5.h),
        ...list.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 0.8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 4, color: color.withValues(alpha: 0.5)),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  item, 
                  style: TextStyle(
                    color: isDark ? Colors.white60 : theme.colorScheme.onSurface.withValues(alpha: 0.75), 
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        )),
        SizedBox(height: 3.h),
      ],
    );
  }

  Widget _buildGradeBadge(String grade, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(grade, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPopularTargetRoles(BuildContext context, AIResumeMatcherProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final roles = [
      {'title': 'Data Science', 'desc': 'Focus on data analysis, machine learning models, and statistical insights using Python, R, and SQL.'},
      {'title': 'Full Stack', 'desc': 'Develop both front-end and back-end web solutions using modern frameworks like React and Node.js.'},
      {'title': 'Mobile Dev', 'desc': 'Build cross-platform mobile applications using Flutter or React Native with focus on performance and UX.'},
      {'title': 'Product Mgmt', 'desc': 'Lead product development lifecycles, from strategy and roadmapping to user research and execution.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Benchmark Popular Roles"),
        SizedBox(height: 1.5.h),
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
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                  ),
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : (isDark ? Colors.white60 : theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      final jobText = "Title: ${role['title']}\nDescription: ${role['desc']}";
                      _jobDescController.text = jobText;
                      provider.updateJobDescription(jobText);
                      setState(() => _selectedApplication = null);
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

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.35), 
        fontSize: 12,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Text(
      text.toUpperCase(), 
      style: TextStyle(
        fontSize: 11.sp, 
        fontWeight: FontWeight.bold, 
        color: isDark ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.45), 
        letterSpacing: 1.2,
      ),
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextStyle(
      fontSize: 12.sp, 
      fontWeight: FontWeight.bold, 
      color: isDark ? Colors.white38 : theme.colorScheme.onSurface.withValues(alpha: 0.5), 
      letterSpacing: 1,
    );
  }
}
