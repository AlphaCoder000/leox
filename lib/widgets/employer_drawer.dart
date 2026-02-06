import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/views/employer/employer_dashboard_view.dart';
import 'package:leox/views/employer/employer_jobs_list_view.dart';

class EmployerDrawer extends StatelessWidget {
  final EmployerDrawerItem selectedItem;

  const EmployerDrawer({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          // 🔹 HEADER
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
            ),
            child: Row(
              children: [
                Icon(Icons.work_outline, size: 28, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  "LeoRecruit",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          _drawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
            isSelected: selectedItem == EmployerDrawerItem.dashboard,
            onTap: () {
              _navigate(context, const EmployerDashboardView());
            },
          ),

          _drawerItem(
            context,
            icon: Icons.work_outline,
            title: "Jobs",
            isSelected: selectedItem == EmployerDrawerItem.jobs,
            onTap: () {
              _navigate(context, const EmployerJobsListView());
            },
          ),

          _drawerItem(
            context,
            icon: Icons.people_outline,
            title: "Candidates",
            isSelected: selectedItem == EmployerDrawerItem.candidates,
            onTap: () {},
          ),

          _drawerItem(
            context,
            icon: Icons.smart_toy_outlined,
            title: "AI Resume Matcher",
            isSelected: selectedItem == EmployerDrawerItem.aiMatcher,
            onTap: () {},
          ),

          _drawerItem(
            context,
            icon: Icons.person_outline,
            title: "My Profile",
            isSelected: selectedItem == EmployerDrawerItem.profile,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ================= HELPER =================

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color:
            isSelected
                ? colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: colorScheme.primary.withOpacity(0.08),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
