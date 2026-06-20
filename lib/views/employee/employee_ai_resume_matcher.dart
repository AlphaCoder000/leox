import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../providers/ai_resume_matcher_provider.dart';
import '../../providers/job_application_provider.dart';
import '../../widgets/employee_drawer.dart';
import '../../models/job_application_model.dart';
import '../../widgets/custom_popup.dart';

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
                  fontSize: 16.sp, 
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
    final secondaryTextColor = isDark ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final resumeBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
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
                  color: Colors.indigoAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.indigoAccent),
              ),
              SizedBox(width: 3.w),
              Text(
                "Analysis Parameters", 
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          _buildLabel(context, "Target Job Description"),
          SizedBox(height: 1.2.h),
          TextField(
            controller: _jobDescController,
            maxLines: 5,
            style: TextStyle(color: primaryTextColor, fontSize: 13.sp),
            onChanged: provider.updateJobDescription,
            decoration: InputDecoration(
              hintText: "Enter details, skills, and tools of your target job...",
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.35), 
                fontSize: 16.sp,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), 
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), 
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), 
                borderSide: BorderSide(color: Colors.indigoAccent, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          _buildLabel(context, "Your Resume"),
          SizedBox(height: 1.2.h),
          
          InkWell(
            onTap: provider.isUploading ? null : () => provider.pickResumeFile(),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
              decoration: BoxDecoration(
                color: provider.selectedResumeFileName != null
                    ? (isDark ? const Color(0xFF132F27) : const Color(0xFFECFDF5))
                    : resumeBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.selectedResumeFileName != null ? Colors.greenAccent : borderCol,
                  width: 1.5,
                ),
                boxShadow: provider.selectedResumeFileName != null
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: isDark ? 0.15 : 0.05),
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
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                        color: Colors.indigoAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        "Ingesting Data... ${(provider.uploadProgress * 100).toInt()}%",
                        style: TextStyle(fontSize: 14.sp, color: Colors.indigoAccent, fontWeight: FontWeight.bold),
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
                                    color: primaryTextColor,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  provider.selectedResumeFileName!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.change_circle_outlined, color: Colors.indigoAccent),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, color: Colors.indigoAccent),
                          SizedBox(width: 3.w),
                          Text(
                            "Choose Resume Document",
                            style: TextStyle(
                              color: Colors.indigoAccent,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
          ),

          SizedBox(height: 4.h),

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
                : () async {
                    final success = await provider.matchResumeToJob();
                    if (!success && context.mounted) {
                      CustomPopup.show(
                        context,
                        type: CustomPopupType.error,
                        title: "Analysis Failed",
                        message: provider.errorMessage,
                        buttonLabel: "OK",
                      );
                    }
                  },
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
                    "Generate Match Score",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
            ),
          ),

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
      {
        'title': 'Mechanical Design',
        'desc': 'Focus on designing mechanical components, 3D modeling, and tolerance analysis using CAD/CAE tools like SolidWorks and ANSYS.'
      },
      {
        'title': 'HVAC Specialist',
        'desc': 'Focus on HVAC system design, thermal analysis, energy modeling, and refrigeration systems complying with ASHRAE standards.'
      },
      {
        'title': 'Robotics & Controls',
        'desc': 'Integrate mechanical parts with electronics and control systems. Kinematics, PLC/microcontrollers, and sensor feedback loops.'
      },
      {
        'title': 'Manufacturing & Lean',
        'desc': 'Optimize manufacturing lines, tooling design, CNC programming, and Lean Six Sigma methodology for efficiency and quality.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Benchmark Popular Roles"),
        SizedBox(height: 1.2.h),
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
                    setState(() => _selectedApplication = null);
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
                      color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
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
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                          fontSize: 16.sp,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Text(
      text.toUpperCase(), 
      style: TextStyle(
        fontSize: 17.sp, 
        fontWeight: FontWeight.bold, 
        color: isDark ? const Color.fromARGB(59, 11, 11, 11) : theme.colorScheme.onSurface.withValues(alpha: 0.85), 
        letterSpacing: 1.2,
      ),
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextStyle(
      fontSize: 16.sp, 
      fontWeight: FontWeight.bold, 
      color: isDark ? Colors.white38 : theme.colorScheme.onSurface.withValues(alpha: 0.6), 
      letterSpacing: 1,
    );
  }
}
