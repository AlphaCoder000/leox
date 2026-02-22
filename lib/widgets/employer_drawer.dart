import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/views/employer/employer_ai_resume_matcher.dart';
import 'package:leox/views/employer/candidates_view.dart';
import 'package:leox/views/employer/employer_dashboard_view.dart';
import 'package:leox/views/employer/employer_jobs_list_view.dart';
import 'package:leox/views/employer/employer_profile_view.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:sizer/sizer.dart';

class EmployerDrawer extends StatelessWidget {
  final EmployerDrawerItem selectedItem;

  const EmployerDrawer({super.key, required this.selectedItem});

  static const Color _drawerBg = Color(0xFF0B1220);
  static const Color _drawerDivider = Color(0xFF1C2536);

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
              color: _drawerBg,
              border: Border(bottom: BorderSide(color: _drawerDivider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.work_rounded,
                    size: 22.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  "LeoRecruit",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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
                  activeIcon: Icons.dashboard_rounded,
                  title: "Dashboard",
                  isSelected: selectedItem == EmployerDrawerItem.dashboard,
                  onTap:
                      () => _navigate(context, const EmployerDashboardView()),
                ),

                _drawerItem(
                  context,
                  icon: Icons.work_outline_rounded,
                  activeIcon: Icons.work_rounded,
                  title: "Jobs",
                  isSelected: selectedItem == EmployerDrawerItem.jobs,
                  onTap: () => _navigate(context, const EmployerJobsListView()),
                ),

                _drawerItem(
                  context,
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  title: "Candidates",
                  isSelected: selectedItem == EmployerDrawerItem.candidates,
                  onTap:
                      () => _navigate(context, const CandidatesView()),
                ),

                _drawerItem(
                  context,
                  icon: Icons.smart_toy_outlined,
                  activeIcon: Icons.smart_toy_rounded,
                  title: "AI Resume Matcher",
                  isSelected: selectedItem == EmployerDrawerItem.aiMatcher,
                  onTap:
                      () => _navigate(
                        context,
                        const EmployerAiResumeMatcherView(),
                      ),
                ),

                Divider(height: 4.h, color: _drawerDivider),

                _drawerItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  title: "My Profile",
                  isSelected: selectedItem == EmployerDrawerItem.profile,
                  onTap: () => _navigate(context, const EmployerProfileView()),
                ),

                Divider(height: 4.h, color: _drawerDivider),

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
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= NORMAL ITEM =================
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
        elevation: isSelected ? 8 : 0,
        shadowColor: colorScheme.primary.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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
                          : Colors.white.withValues(alpha: 0.65),
                ),
                SizedBox(width: 4.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85),
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
                  fontSize: 12.sp,
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleOptionView()),
                    (route) => false,
                  );
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
