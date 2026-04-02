import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/employer_profile_provider.dart';
import 'package:leox/providers/employer_auth_provider.dart';
import 'package:leox/views/employer/employer_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/providers/theme_povider.dart';

import '../../providers/employer_dashboard_provider.dart';
import '../../widgets/employer_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../providers/notification_provider.dart';
import '../common/notifications_view.dart'; // Reusing the same view for notifications

class EmployerDashboardView extends StatefulWidget {
  const EmployerDashboardView({super.key});

  @override
  State<EmployerDashboardView> createState() => _EmployerDashboardViewState();
}

class _EmployerDashboardViewState extends State<EmployerDashboardView> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data and profile when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EmployerDashboardProvider>().loadDashboard();
        context.read<EmployerProfileProvider>().loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<EmployerDashboardProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.dashboard),

      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          Consumer<ThemeProvider>(
            builder:
                (context, themeProvider, _) => IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.light_mode_outlined
                        : themeProvider.themeMode == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.settings_system_daydream_outlined,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
          ),
          // 🔔 NOTIFICATIONS
          Consumer<NotificationProvider>(
            builder:
                (context, notificationProvider, _) => IconButton(
                  icon: Badge(
                    label: Text(notificationProvider.unreadCount.toString()),
                    isLabelVisible: notificationProvider.unreadCount > 0,
                    child: const Icon(Icons.notifications_none_outlined),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsView(),
                      ),
                    );
                  },
                ),
          ),

          SizedBox(width: 1.w),

          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) async {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployerProfileView(),
                    ),
                  );
                } else if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (_) {
                final profile = context.read<EmployerProfileProvider>().profile;
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name.isNotEmpty ? profile.name : "Employer",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          profile.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                ];
              },
              child: Consumer<EmployerProfileProvider>(
                builder: (context, profileProvider, child) {
                  final profile = profileProvider.profile;
                  if ((profile.profilePicture ?? '').isNotEmpty) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(profile.profilePicture!),
                      backgroundColor: colorScheme.primary,
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      profile.companyName.isNotEmpty
                          ? profile.companyName[0].toUpperCase()
                          : "A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(3.w), // Reduced from 4.w to 3.w for more space
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overview",
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Here is your recruitment summary.",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 2.h),

            // 🔹 STATS GRID
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w, // Reduced from 4.w to make cards wider
              mainAxisSpacing: 2.h, // Keep the same vertical spacing
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4, // Reduced from 1.8 to make cards wider (more square)
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
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
                  _pipelineItem(
                    context,
                    "Applied",
                    dashboard.pending,
                    Colors.blue,
                  ),
                  _pipelineItem(
                    context,
                    "Reviewed",
                    dashboard.reviewed,
                    Colors.purple,
                  ),
                  _pipelineItem(
                    context,
                    "Shortlisted",
                    dashboard.shortlisted,
                    Colors.orange,
                  ),
                  _pipelineItem(
                    context,
                    "Hired",
                    dashboard.hired,
                    Colors.green,
                  ),
                  _pipelineItem(
                    context,
                    "Rejected",
                    dashboard.rejected,
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
                    //alpha: 0.5,
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
                  fontSize: 16.sp,
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
              count.toInt().toString(),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF0B1220),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF1C2536)),
            ),
            title: Row(
              children: [
                const Icon(Icons.logout_rounded, color: Colors.redAccent),
                SizedBox(width: 3.w),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to sign out of your employer account?",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.sp,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11.sp,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.2.h,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    // Clear any sub-pages and return to root before logout
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await context.read<EmployerAuthProvider>().logout();
                  },
                  child: Text(
                    "Yes, Logout",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
