import 'package:flutter/material.dart';
import 'package:leox/utils/route_guard.dart';
import 'package:leox/views/employee/employee_ai_resume_matcher.dart';
import 'package:leox/views/employee/employee_dashboard_view.dart';
import 'package:leox/views/employee/employee_jobs_list_view.dart';
import 'package:leox/views/employee/employee_profile_view.dart';
import 'package:sizer/sizer.dart';

enum EmployeeDrawerItem { dashboard, jobs, aiMatcher, profile }

class EmployeeDrawer extends StatelessWidget {
  final EmployeeDrawerItem selectedItem;

  const EmployeeDrawer({super.key, required this.selectedItem});

  static const Color _drawerBg = Color(0xFF0B1220);
  static const Color _divider = Color(0xFF1C2536);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: _drawerBg,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: EdgeInsets.fromLTRB(6.w, 7.h, 4.w, 3.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _divider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: colorScheme.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  "LeoRecruit",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // ================= MENU =================
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              children: [
                _drawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: "Dashboard",
                  isSelected: selectedItem == EmployeeDrawerItem.dashboard,
                  onTap:
                      () => _navigate(context, const EmployeeDashboardView()),
                ),

                _drawerItem(
                  context,
                  icon: Icons.work_outline,
                  activeIcon: Icons.work,
                  title: "Jobs",
                  isSelected: selectedItem == EmployeeDrawerItem.jobs,
                  onTap: () {
                    _navigate(context, const EmployeeJobsListView());
                  },
                ),

                _drawerItem(
                  context,
                  icon: Icons.smart_toy_outlined,
                  activeIcon: Icons.smart_toy,
                  title: "AI Resume Matcher",
                  isSelected: selectedItem == EmployeeDrawerItem.aiMatcher,
                  onTap: () {
                    _navigate(context, const EmployeeAiResumeMatcherView());
                  },
                ),

                _drawerItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: "My Profile",
                  isSelected: selectedItem == EmployeeDrawerItem.profile,
                  onTap: () {
                    // For now, just navigate to dashboard (since profile view is not ready)
                    _navigate(context, const EmployeeProfileView());
                  },
                ),

                Divider(height: 4.h, color: _divider),

                // ================= LOGOUT =================
                _logoutItem(context),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              "v1.0.0",
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DRAWER ITEM =================
  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Material(
        elevation: isSelected ? 6 : 0,
        shadowColor: colorScheme.primary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: colorScheme.primary.withOpacity(0.15),
          highlightColor: colorScheme.primary.withOpacity(0.08),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 18.sp,
                  color:
                      isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.65),
                ),
                SizedBox(width: 4.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT ITEM =================
  Widget _logoutItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _confirmLogout(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18.sp, color: Colors.redAccent),
              SizedBox(width: 4.w),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT DIALOG =================
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Use RouteGuard to handle logout with proper cleanup
                  RouteGuard.handleLogout(context);
                },
                child: const Text("Logout"),
              ),
            ],
          ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
