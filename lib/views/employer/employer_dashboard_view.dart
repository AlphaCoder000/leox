import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/views/employer/employer_profile_view.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/employer_dashboard_provider.dart';
import '../../widgets/employer_drawer.dart';
import '../../widgets/stat_card.dart';

class EmployerDashboardView extends StatelessWidget {
  const EmployerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<EmployerDashboardProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.dashboard),

      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // 🌗 THEME MENU
          PopupMenuButton<String>(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: colorScheme.onSurface,
            ),
            onSelected: (value) {
              final themeProvider = context.read<ThemeProvider>();
              if (value == 'light') themeProvider.setLight();
              if (value == 'dark') themeProvider.setDark();
              if (value == 'system') themeProvider.setSystem();
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
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployerProfileView(),
                    ),
                  );
                } else if (value == 'logout') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleOptionView()),
                    (route) => false,
                  );
                }
              },
              itemBuilder:
                  (_) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Akash More",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "akashmoreasm6000@gmail.com",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text("My Profile"),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text("Logout")),
                  ],
              child: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: const Text(
                  "A",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
              "Overview",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Here is your recruitment summary.",
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 3.h),

            // 🔹 STATS GRID
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 2.h,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  title: "Total Jobs",
                  value: dashboard.totalJobs,
                  subtitle: "Active posts",
                  icon: Icons.work_outline_rounded,
                ),
                StatCard(
                  title: "Candidates",
                  value: dashboard.totalCandidates,
                  subtitle: "Total applications",
                  icon: Icons.people_alt_outlined,
                ),
                StatCard(
                  title: "Shortlisted",
                  value: dashboard.shortlisted,
                  subtitle: "Passed screening",
                  icon: Icons.check_circle_outline_rounded,
                ),
                StatCard(
                  title: "Hired",
                  value: dashboard.hired,
                  subtitle: "Offer accepted",
                  icon: Icons.verified_outlined,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            Text(
              "Candidate Pipeline",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),

            // ... keep pipeline ...
            SizedBox(height: 2.h),

            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              child: Column(
                children: [
                  _pipelineItem(context, "Applied", 12, Colors.blue),
                  _pipelineItem(
                    context,
                    "Shortlisted",
                    dashboard.shortlisted,
                    Colors.orange,
                  ),
                  _pipelineItem(
                    context,
                    "Interview Scheduled",
                    3,
                    Colors.purple,
                  ),
                  _pipelineItem(context, "Interviewed", 2, Colors.teal),
                  _pipelineItem(
                    context,
                    "Hired",
                    dashboard.hired,
                    Colors.green,
                  ),
                  _pipelineItem(
                    context,
                    "Rejected",
                    4,
                    Colors.red,
                    isLast: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  // ================== UI WIDGETS ==================

  Widget _pipelineItem(
    BuildContext context,
    String stage,
    int count,
    Color color, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration:
          isLast
              ? null
              : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
              ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 3.w),
              Text(
                stage,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
