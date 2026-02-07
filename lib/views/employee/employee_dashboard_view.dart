import 'package:flutter/material.dart';
import 'package:leox/providers/employee/employee_dashboard_provider.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/views/employee/employee_profile_provider.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:leox/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<EmployeeDashboardProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.dashboard),

      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // 🌗 THEME MENU (Light / Dark / System)
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
                (context) => const [
                  PopupMenuItem(value: 'light', child: Text("Light")),
                  PopupMenuItem(value: 'dark', child: Text("Dark")),
                  PopupMenuItem(value: 'system', child: Text("System")),
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
                      builder: (_) => const EmployeeProfileView(),
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
              "Dashboard",
              style: TextStyle(
                fontSize: 19.sp, // 🔼 slightly bigger
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              "Your personal application overview.",
              style: TextStyle(
                fontSize: 13.sp, // 🔼 slightly bigger
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 3.h),

            // 🔹 STATS
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 2.h,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: "Applications Sent",
                  value: dashboard.applicationsSent,
                  subtitle: "Total jobs you have applied for.",
                  icon: Icons.description_outlined,
                ),
                StatCard(
                  title: "Active Applications",
                  value: dashboard.activeApplications,
                  subtitle: "Applications under review.",
                  icon: Icons.access_time_outlined,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // 🔹 ACTIVITY FEED
            Card(
              elevation: 1, // 🔽 reduced blur
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
                      "Your Activity Feed",
                      style: TextStyle(
                        fontSize: 16.sp, // 🔼
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      "Updates on your job applications",
                      style: TextStyle(
                        fontSize: 12.sp, // 🔼
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 42.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 1.2.h),
                          Text(
                            "No activities found.",
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            "Your application updates will appear here.",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
