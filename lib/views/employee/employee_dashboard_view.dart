import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:leox/providers/employee_providers/employee_dashboard_provider.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:leox/utils/route_guard.dart';
import 'package:leox/utils/error_handler_ui.dart';
import 'package:leox/views/employee/employee_profile_view.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:leox/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Validate session when app resumes from background
    if (state == AppLifecycleState.resumed) {
      debugPrint('[EmployeeDashboard] App resumed, validating session...');
      _validateSession();
    }
  }

  Future<void> _validateSession() async {
    if (!mounted) return;

    final isValid = await RouteGuard.validateSession(context);
    if (!isValid && mounted) {
      debugPrint('[EmployeeDashboard] Session validation failed, logging out');
      final authProvider = context.read<EmployeeAuthProvider>();
      await authProvider.logout();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/role-option', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired, please login again'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load dashboard data on first build
    final dashboardProvider = context.read<EmployeeDashboardProvider>();
    dashboardProvider.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<EmployeeDashboardProvider>();
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
                  // Use RouteGuard to handle logout with proper cleanup
                  RouteGuard.handleLogout(context);
                }
              },
              itemBuilder: (_) {
                final authProvider = context.read<EmployeeAuthProvider>();
                final email = authProvider.userEmail ?? 'Employee';
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.isEmpty ? "Employee" : email.split('@')[0],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
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

      body: Consumer<EmployeeDashboardProvider>(
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
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  "Your personal application overview.",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: 3.h),

                // 🔹 STATS ROW 1
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

                SizedBox(height: 2.h),

                // 🔹 STATS ROW 2
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 2.h,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    StatCard(
                      title: "Offers Received",
                      value: dashboard.acceptedOffers,
                      subtitle: "Job offers received.",
                      icon: Icons.card_giftcard_outlined,
                    ),
                    StatCard(
                      title: "Rejected",
                      value: dashboard.rejectedApplications,
                      subtitle: "Applications rejected.",
                      icon: Icons.close_outlined,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${dashboard.profileCompletionPercentage.toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: dashboard.profileCompletionPercentage / 100,
                            minHeight: 8,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              dashboard.profileCompletionPercentage >= 80
                                  ? Colors.green
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          dashboard.profileCompletionPercentage >= 80
                              ? "Great! Your profile looks complete."
                              : "Complete your profile to improve visibility.",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          "Your latest job applications",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),

                        SizedBox(height: 3.h),

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
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                                SizedBox(height: 0.4.h),
                                Text(
                                  "Start applying to jobs to see them here.",
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
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
                              return Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                app.companyName,
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: app
                                                .statusColor()
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            app.statusLabel(),
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
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
                                        fontSize: 11.sp,
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
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
    );
  }
}
