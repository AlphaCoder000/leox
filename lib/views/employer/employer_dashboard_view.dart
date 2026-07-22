import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/employer_profile_provider.dart';
import 'package:leox/providers/employer_auth_provider.dart';
import 'package:leox/views/employer/employer_profile_view.dart';
import 'package:leox/views/employer/create_job_view.dart';
import 'package:leox/views/employer/employer_jobs_list_view.dart';
import 'package:leox/views/employer/candidates_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/providers/subscription_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:leox/widgets/subscription_status_badge.dart';

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
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          context.read<SubscriptionProvider>().listenToSubscription(uid, 'employer');
        }
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

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.dashboard),

      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          const SubscriptionStatusBadge(),
          SizedBox(width: 2.w),
          Consumer<ThemeProvider>(
            builder:
                (context, themeProvider, _) => IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
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
            child: GestureDetector(
              onTap: () {
                final profile = context.read<EmployerProfileProvider>().profile;
                _showProfileBottomSheet(context, profile);
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

      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                3.w,
              ), // Reduced from 4.w to 3.w for more space
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
                  SizedBox(height: 1.h),
                  Text(
                    "Here is your recruitment summary.",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // 🔹 RECRUITMENT SUMMARY CARD
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: colorScheme.primary,
                                size: 20.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "Recruitment Summary",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.3,
                            children: [
                              StatCard(
                                title: "Total Jobs",
                                value: dashboard.totalJobs,
                                subtitle: "Active posts",
                                icon: Icons.work_outline_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EmployerJobsListView(),
                                    ),
                                  );
                                },
                              ),
                              StatCard(
                                title: "Candidates",
                                value: dashboard.totalCandidates,
                                subtitle: "Total applications",
                                icon: Icons.people_alt_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CandidatesView(),
                                    ),
                                  );
                                },
                              ),
                              StatCard(
                                title: "Shortlisted",
                                value: dashboard.shortlisted,
                                subtitle: "Passed screening",
                                icon: Icons.check_circle_outline_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CandidatesView(),
                                    ),
                                  );
                                },
                              ),
                              StatCard(
                                title: "Hired",
                                value: dashboard.hired,
                                subtitle: "Offer accepted",
                                icon: Icons.verified_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CandidatesView(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 2.5.h),

                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _quickActionButton(
                            context,
                            title: "Post Job",
                            subtitle: "Create new listing",
                            icon: Icons.add_circle_outline_rounded,
                            color: theme.colorScheme.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateJobView()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 3.5.w),
                        Expanded(
                          child: _quickActionButton(
                            context,
                            title: "View Job Posting",
                            subtitle: "Manage active jobs",
                            icon: Icons.pageview_outlined,
                            color: const Color(0xFF10B981),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EmployerJobsListView()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.5.h),

                  Text(
                    "Candidate Pipeline",
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  // ... keep pipeline ...
                  SizedBox(height: 1.h),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 2.h,
                      horizontal: 4.w,
                    ),
                    child: Column(
                      children: [
                        _pipelineItem(
                          context,
                          "Applied",
                          dashboard.pending,
                          theme.colorScheme.primary,
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
          ),
        ],
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
                    color: theme.dividerColor.withValues(alpha: 0.5),
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
              color: color.withValues(alpha: 0.1),
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
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12.sp,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
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

  void _showProfileBottomSheet(BuildContext parentContext, dynamic profile) {
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: (profile.profilePicture ?? '').isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profile.profilePicture!),
                        backgroundColor: theme.colorScheme.primary,
                      )
                    : CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          profile.companyName.isNotEmpty
                              ? profile.companyName[0].toUpperCase()
                              : (profile.name.isNotEmpty ? profile.name[0].toUpperCase() : "E"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                title: Text(
                  profile.name.isNotEmpty ? profile.name : "Employer",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(profile.email),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text("My Profile"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (_) => const EmployerProfileView(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showLogoutDialog(parentContext);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.02 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20.sp,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
