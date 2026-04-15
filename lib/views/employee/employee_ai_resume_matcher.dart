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
    final colorScheme = theme.colorScheme;
    final provider = context.watch<AIResumeMatcherProvider>();
    final appsProvider = context.watch<JobApplicationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.aiMatcher),
      appBar: AppBar(
        title: const Text("Career Intelligence"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              provider.clearAll();
              _jobDescController.clear();
              _resumeTextController.clear();
              setState(() => _selectedApplication = null);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF030712), Color(0xFF0F172A)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= PAGE HEADER =================
              _buildHeader(colorScheme),

              SizedBox(height: 4.h),

              // ================= SELECT APPLICATION =================
              if (appsProvider.applications.isNotEmpty) ...[
                _buildLabel(context, "Analyze an Existing Application"),
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<JobApplicationModel>(
                      value: _selectedApplication,
                      hint: const Text("Choose an application", style: TextStyle(color: Colors.grey)),
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      items: appsProvider.applications.map((app) {
                        return DropdownMenuItem(
                          value: app,
                          child: Text(app.jobTitle, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (app) => _onApplicationSelected(app, provider),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
              ],

              // ================= QUICK TARGET ROLES =================
              _buildPopularTargetRoles(provider),

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

  Widget _buildHeader(ColorScheme colorScheme) {
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
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "Let AI review your resume against any role",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context, AIResumeMatcherProvider provider) {
    //final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Colors.indigoAccent),
              SizedBox(width: 2.w),
              Text("Analysis Scope", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          SizedBox(height: 3.h),

          _buildLabel(context, "Target Job Description"),
          SizedBox(height: 1.2.h),
          TextField(
            controller: _jobDescController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: provider.updateJobDescription,
            decoration: _inputDecoration("Paste the requirements of the job you want..."),
          ),

          SizedBox(height: 3.h),

          _buildLabel(context, "Your Resume"),
          SizedBox(height: 1.2.h),
          
          InkWell(
            onTap: provider.isUploading ? null : () => provider.pickResumeFile(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: provider.selectedResumeFileName != null ? Colors.indigoAccent : Colors.transparent,
                ),
              ),
              child: provider.isUploading
                ? LinearProgressIndicator(value: provider.uploadProgress, backgroundColor: Colors.white10)
                : Row(
                    children: [
                      Icon(
                        provider.selectedResumeFileName != null ? Icons.file_present_rounded : Icons.upload_rounded,
                        color: provider.selectedResumeFileName != null ? Colors.indigoAccent : Colors.white24,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          provider.selectedResumeFileName ?? "Upload PDF or Text Resume",
                          style: TextStyle(color: provider.selectedResumeFileName != null ? Colors.white : Colors.white38),
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
    if (provider.matchResults.isEmpty) {
      return Container(
        height: 20.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: Text("AI results will appear here", style: TextStyle(color: Colors.white24, fontSize: 13.sp, fontWeight: FontWeight.bold,)),
        ),
      );
    }

    final results = provider.matchResults;
    final overallScore = (results['overallScore'] as num?)?.toDouble() ?? 0.0;
    final scoreColor = Color(int.parse(provider.getScoreColor(overallScore).replaceAll('#', '0xFF')));

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Match report", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              _buildGradeBadge(provider.getScoreGrade(overallScore), scoreColor),
            ],
          ),
          SizedBox(height: 4.h),

          _buildMatchCircle(overallScore, scoreColor),

          SizedBox(height: 4.h),

          if (results['analysis'] != null) ...[
            Text("SUMMARY", style: _sectionTitleStyle),
            SizedBox(height: 1.h),
            Text(results['analysis'], style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
            SizedBox(height: 3.h),
          ],

          _buildBreakdown(results),

          SizedBox(height: 4.h),

          if (results['strengths'] != null) _buildPointList("STRENGTHS", results['strengths'], Colors.greenAccent),
          if (results['gaps'] != null) _buildPointList("GAPS", results['gaps'], Colors.orangeAccent),
          if (results['recommendations'] != null) _buildPointList("RECOMMENDATIONS", results['recommendations'], Colors.indigoAccent),
        ],
      ),
    );
  }

  Widget _buildMatchCircle(double score, Color color) {
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
              backgroundColor: Colors.white10,
              color: color,
            ),
          ),
          Text("${score.toInt()}%", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBreakdown(Map<String, dynamic> results) {
    return Row(
      children: [
        Expanded(child: _miniStep("Skills", results['skillsMatch'])),
        Expanded(child: _miniStep("Exp", results['experienceMatch'])),
        Expanded(child: _miniStep("Edu", results['educationMatch'])),
      ],
    );
  }

  Widget _miniStep(String label, dynamic score) {
    final s = (score as num?)?.toDouble() ?? 0.0;
    return Column(
      children: [
        Text("${s.toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildPointList(String title, dynamic items, Color color) {
    final list = items as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
        SizedBox(height: 1.5.h),
        ...list.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 0.8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 4, color: color.withValues(alpha: 0.5)),
              SizedBox(width: 3.w),
              Expanded(child: Text(item, style: const TextStyle(color: Colors.white60, fontSize: 12))),
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

  Widget _buildPopularTargetRoles(AIResumeMatcherProvider provider) {
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
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(text.toUpperCase(), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.2));
  }

  TextStyle get _sectionTitleStyle => TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1);
}

