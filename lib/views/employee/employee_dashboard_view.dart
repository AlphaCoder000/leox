import 'package:flutter/material.dart';
import 'package:leox/providers/employee_providers/employee_dashboard_provider.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/providers/employee_providers/employee_profile_provider.dart';
import 'package:leox/utils/error_handler_ui.dart';
import 'package:leox/views/employee/employee_profile_view.dart';
import 'package:leox/widgets/employee_drawer.dart';
import '../../models/candidate_model.dart';
import '../common/application_details_view.dart';
import 'package:leox/widgets/stat_card.dart';
import '../../providers/notification_provider.dart';
import '../common/notifications_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/providers/theme_povider.dart';

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

          return SingleChildScrollView(
            padding: EdgeInsets.all(3.w), // Reduced from 4.w to match employer dashboard
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 22.sp, fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  "Your personal application overview.",
                  style: TextStyle(
                    fontSize: 17.sp, fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.71),
                  ),
                ),

                SizedBox(height: 1.h),

                // 🔹 STATS GRID
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w, // Reduced from 4.w to match employer dashboard
                  mainAxisSpacing: 2.h, // Keep the same vertical spacing
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4, // Updated from 2.0 to 1.4 to match employer dashboard
                  children: [
                    StatCard(
                      title: "Applications Sent",
                      value: dashboard.totalApplications,
                      subtitle: "Total jobs you have applied for.",
                      icon: Icons.description_outlined,
                    ),
                    StatCard(
                      title: "Under Review",
                      value: dashboard.applicationsUnderReview,
                      subtitle: "Applications under review.",
                      icon: Icons.access_time_outlined,
                    ),
                  ],
                ),

              

                // 🔹 PROFILE COMPLETION
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Profile Completion",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${dashboard.profileCompletionPercentage.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: dashboard.profileCompletionPercentage / 100,
                            minHeight: 1.h,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              dashboard.profileCompletionPercentage >= 80
                                  ? Colors.green
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          dashboard.profileCompletionPercentage >= 80
                              ? "Great! Your profile looks complete."
                              : "Complete your profile to improve visibility.",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 1.h),

                // 🔹 RECENT APPLICATIONS
                Card(
                  elevation: 1,
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
                          "Recent Applications",
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          "Your latest job applications",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),

                        SizedBox(height: 1.h),

                        if (dashboard.recentApplications.isEmpty)
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
                                  "No applications yet.",
                                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold,),
                                ),
                                SizedBox(height: 0.4.h),
                                Text(
                                  "Start applying to jobs to see them here.",
                                  style: TextStyle(
                                    fontSize: 13.sp, fontWeight: FontWeight.bold,
                                    color: Colors.grey,
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
                            separatorBuilder:
                                (_, __) => SizedBox(height: 1.5.h),
                            itemBuilder: (_, index) {
                              final app = dashboard.recentApplications[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => JobApplicationDetailsView(
                                              application:
                                                  CandidateModel.fromEmployeeApplication(
                                                    app,
                                                  ),
                                              isEmployer: false,
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    app.jobTitle,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 19.sp, fontWeight: FontWeight.bold,
                                                          
                                                    ),
                                                  ),
                                                  SizedBox(height: 0.5.h),
                                                  Text(
                                                    app.companyName,
                                                    style: TextStyle(
                                                      fontSize: 17.sp, fontWeight: FontWeight.bold,
                                                      color:
                                                          colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 2.w,
                                                vertical: 0.5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: app
                                                    .statusColor()
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                app.statusLabel(),
                                                style: TextStyle(
                                                  fontSize: 15.sp, fontWeight: FontWeight.w600,
                                                  color: app.statusColor(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 1.5.h),
                                        Text(
                                          app.statusWithDays(),
                                          style: TextStyle(
                                            fontSize: 16.sp, fontWeight: FontWeight.normal,
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
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
