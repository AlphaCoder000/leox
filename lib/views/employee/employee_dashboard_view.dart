import 'package:flutter/material.dart';
import 'package:leox/providers/employee_providers/employee_dashboard_provider.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/providers/employee_providers/employee_profile_provider.dart';
import 'package:leox/utils/error_handler_ui.dart';
import 'package:leox/views/employee/employee_profile_view.dart';
import 'package:leox/views/employee/employee_jobs_list_view.dart';
import 'package:leox/widgets/employee_drawer.dart';
import '../../models/candidate_model.dart';
import '../common/application_details_view.dart';
import 'package:leox/widgets/stat_card.dart';
import '../../providers/notification_provider.dart';
import '../common/notifications_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/utils/app_theme.dart';

class EmployeeDashboardView extends StatefulWidget {
  const EmployeeDashboardView({super.key});

  @override
  State<EmployeeDashboardView> createState() => _EmployeeDashboardViewState();
}

class _EmployeeDashboardViewState extends State<EmployeeDashboardView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Load dashboard data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeDashboardProvider>().loadDashboard();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auth state is now managed reactively by main.dart
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.dashboard),

      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
        actions: [
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

          Consumer<NotificationProvider>(
            builder:
                (context, notificationProvider, _) => Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: IconButton(
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
          ),

          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Consumer2<EmployeeProfileProvider, EmployeeAuthProvider>(
              builder: (context, profileProvider, authProvider, child) {
                final profile = profileProvider.profile;
                final userEmail = authProvider.userEmail ?? 'Employee';
                return GestureDetector(
                  onTap: () {
                    _showProfileBottomSheet(context, profile, userEmail);
                  },
                  child: Builder(
                    builder: (context) {
                      if (profile != null && profile.profilePicture.isNotEmpty) {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(profile.profilePicture),
                          backgroundColor: colorScheme.primary,
                        );
                      }
                      return CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          (profile?.firstName.isNotEmpty ?? false)
                              ? profile!.firstName[0].toUpperCase()
                              : "P",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<EmployeeDashboardProvider>(
          builder: (context, dashboardProvider, _) {
            // Show loading spinner
            if (dashboardProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

          // Show error message with retry option
          if ((dashboardProvider.errorMessage ?? '').isNotEmpty && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ErrorHandlerUI.showErrorSnackbar(
                context,
                dashboardProvider.errorMessage ?? 'Unknown error',
                onRetry: () {
                  dashboardProvider.loadDashboard();
                },
              );
            });
          }

          final dashboard = dashboardProvider.dashboard;
          final isDark = theme.brightness == Brightness.dark;
          final textOnSurface = theme.colorScheme.onSurface;
          final secondaryText = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Cohesive Welcome Header
                Consumer<EmployeeProfileProvider>(
                  builder: (context, profileProvider, _) {
                    final profile = profileProvider.profile;
                    final firstName = profile?.firstName ?? '';
                    final greeting = firstName.isNotEmpty ? "Hello, $firstName! 👋" : "Hello there! 👋";
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [theme.cardColor, theme.cardColor.withValues(alpha: 0.8)]
                              : [colorScheme.primary.withValues(alpha: 0.06), colorScheme.primary.withValues(alpha: 0.02)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: isDark ? 0.01 : 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 0.6.h),
                                Text(
                                  "Track your career opportunities & progress.",
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.dashboard_customize_rounded,
                              color: colorScheme.primary,
                              size: 22.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.5.h),

                // 🔹 QUICK JOBS SHORTCUT
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeJobsListView(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.5.w),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.work_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Find New Jobs",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                "Explore new career opportunities now",
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 15.sp,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.5.h),

                // Section Title: Career Insights
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 15.sp, color: colorScheme.primary),
                    SizedBox(width: 1.5.w),
                    Text(
                      "Career Activity Insights",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: textOnSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),

                // 🔹 STATS GRID
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.5.w,
                  mainAxisSpacing: 2.h,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(
                      title: "Applications Sent",
                      value: dashboard.totalApplications,
                      subtitle: "Total jobs applied",
                      icon: Icons.description_outlined,
                    ),
                    StatCard(
                      title: "Under Review",
                      value: dashboard.applicationsUnderReview,
                      subtitle: "Under hiring review",
                      icon: Icons.access_time_outlined,
                    ),
                  ],
                ),
                SizedBox(height: 2.5.h),

                // 🔹 PROFILE COMPLETION (Tap to edit)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmployeeProfileView()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (dashboard.profileCompletionPercentage >= 80 ? Colors.green : colorScheme.primary)
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.02 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4.5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    dashboard.profileCompletionPercentage >= 80
                                        ? Icons.verified_user_rounded
                                        : Icons.pending_actions_rounded,
                                    color: dashboard.profileCompletionPercentage >= 80 ? Colors.green : colorScheme.primary,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "Profile Completion",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textOnSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: (dashboard.profileCompletionPercentage >= 80 ? Colors.green : colorScheme.primary)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${dashboard.profileCompletionPercentage.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: dashboard.profileCompletionPercentage >= 80 ? Colors.green : colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.5.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: dashboard.profileCompletionPercentage / 100,
                              minHeight: 0.8.h,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                dashboard.profileCompletionPercentage >= 80
                                    ? Colors.green
                                    : colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  dashboard.profileCompletionPercentage >= 80
                                      ? "Excellent! Your profile is highly visible to employers."
                                      : "Complete your profile details to stand out to recruiters.",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12.sp,
                                color: secondaryText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // 🔹 RECENT APPLICATIONS HEADER
                Row(
                  children: [
                    Icon(Icons.work_history_outlined, size: 15.sp, color: colorScheme.primary),
                    SizedBox(width: 1.5.w),
                    Text(
                      "Recent Applications Feed",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: textOnSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                if (dashboard.recentApplications.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 42.sp,
                          color: secondaryText.withValues(alpha: 0.5),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          "No active applications yet",
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: textOnSurface),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          "Explore available jobs and start applying!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboard.recentApplications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 2.h),
                    itemBuilder: (_, index) {
                      final app = dashboard.recentApplications[index];
                      final statusColor = app.statusColor();
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: isDark ? 0.02 : 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobApplicationDetailsView(
                                    application: CandidateModel.fromEmployeeApplication(app),
                                    isEmployer: false,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(4.5.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              app.jobTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: textOnSurface,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              app.companyName,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 0.6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          app.statusLabel(),
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  Divider(color: theme.dividerColor.withValues(alpha: 0.5), height: 1),
                                  SizedBox(height: 2.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 13.sp,
                                            color: secondaryText,
                                          ),
                                          SizedBox(width: 1.5.w),
                                          Text(
                                            app.statusWithDays(),
                                            style: TextStyle(
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.w500,
                                              color: secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 13.sp,
                                        color: secondaryText,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 3.h),
              ],
            ),
          );
        },
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
                    fontSize: 18.sp, fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to sign out of your employee account?",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.sp, fontWeight: FontWeight.normal,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13.sp, fontWeight: FontWeight.normal,
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
                    // Close dialog
                    Navigator.of(dialogContext).pop();

                    // Clear any sub-pages and return to root before logout
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    final auth = context.read<EmployeeAuthProvider>();
                    final profile = context.read<EmployeeProfileProvider>();

                    await auth.logout();
                    profile.reset();
                  },
                  child: Text(
                    "Yes, Logout",
                    style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showProfileBottomSheet(BuildContext parentContext, dynamic profile, String userEmail) {
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        final displayName = userEmail.isEmpty ? "Employee" : userEmail.split('@')[0];
        
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
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userEmail),
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
                      builder: (_) => const EmployeeProfileView(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
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
}
