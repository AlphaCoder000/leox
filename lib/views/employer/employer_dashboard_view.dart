import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/employer_dashboard_provider.dart';
import '../../widgets/employer_drawer.dart';

class EmployerDashboardView extends StatelessWidget {
  const EmployerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<EmployerDashboardProvider>();
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        const Color.fromRGBO(0, 0, 0, 1);

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.dashboard),

      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // 🌗 THEME MENU (LIKE WEB)
          PopupMenuButton<String>(
            icon: const Icon(Icons.brightness_6_outlined),
            onSelected: (value) {
              final theme = context.read<ThemeProvider>();

              if (value == 'light') theme.setLight();
              if (value == 'dark') theme.setDark();
              if (value == 'system') theme.setSystem();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'light', child: Text("Light")),
                  const PopupMenuItem(value: 'dark', child: Text("Dark")),
                  const PopupMenuItem(value: 'system', child: Text("System")),
                ],
          ),

          SizedBox(width: 2.w),

          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: const CircleAvatar(
              backgroundColor: Color.fromRGBO(66, 133, 244, 1),
              child: Text(
                "A",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overview of your recruitment process",
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor.withOpacity(0.8),
              ),
            ),

            SizedBox(height: 3.h),

            // 🔹 STATS GRID
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 3.h,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                _statCard(
                  context,
                  "Total Jobs",
                  dashboard.totalJobs,
                  Icons.work_outline,
                ),
                _statCard(
                  context,
                  "Candidates",
                  dashboard.totalCandidates,
                  Icons.people_outline,
                ),
                _statCard(
                  context,
                  "Shortlisted",
                  dashboard.shortlisted,
                  Icons.check_circle_outline,
                ),
                _statCard(
                  context,
                  "Hired",
                  dashboard.hired,
                  Icons.verified_outlined,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            Text(
              "Candidate Pipeline",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),

            SizedBox(height: 2.h),

            _pipelineItem(context, "Applied", 12),
            _pipelineItem(context, "Shortlisted", dashboard.shortlisted),
            _pipelineItem(context, "Interview Scheduled", 3),
            _pipelineItem(context, "Interviewed", 2),
            _pipelineItem(context, "Hired", dashboard.hired),
            _pipelineItem(context, "Rejected", 4),
          ],
        ),
      ),
    );
  }

  // ================== UI WIDGETS ==================

  Widget _statCard(
    BuildContext context,
    String title,
    int value,
    IconData icon,
  ) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        const Color.fromRGBO(0, 0, 0, 1);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color.fromRGBO(66, 133, 244, 1), size: 26),

            const Spacer(),

            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            SizedBox(height: 0.5.h),

            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pipelineItem(BuildContext context, String stage, int count) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        const Color.fromRGBO(0, 0, 0, 1);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stage, style: TextStyle(fontSize: 15.sp, color: textColor)),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
