import 'package:flutter/material.dart';
import 'package:leox/providers/employee/employee_profile_provider.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EmployeeProfileView extends StatelessWidget {
  const EmployeeProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<EmployeeProfileProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.dashboard),
      appBar: AppBar(title: const Text("My Profile")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Profile",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.5.h),
            Text(
              "View and manage your personal information.",
              style: TextStyle(
                fontSize: 12.5.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: 3.h),

            // ================= PROFILE CARD =================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withOpacity(0.15),
                      child: Text(
                        profile.name[0],
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // ================= PERSONAL INFO =================
            _infoCard(
              context,
              title: "Personal Information",
              subtitle: "Your contact and qualification details.",
              showEdit: true,
              children: [
                _infoRow(Icons.person_outline, profile.name),
                _infoRow(Icons.email_outlined, profile.email),
                _infoRow(Icons.phone_outlined, profile.phone),
                _infoRow(
                  Icons.location_on_outlined,
                  profile.location.isEmpty ? "Not provided" : profile.location,
                ),
              ],
            ),

            SizedBox(height: 2.5.h),

            // ================= RESUME =================
            _infoCard(
              context,
              title: "My Resume",
              subtitle:
                  "Upload a resume to auto-fill your profile information.",
              children: [
                Text(
                  profile.resumePath.isEmpty
                      ? "You have not uploaded a resume yet."
                      : "Resume uploaded",
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 1.5.h),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: File picker + parsing
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text("Upload & Parse Resume"),
                ),
              ],
            ),

            SizedBox(height: 2.5.h),

            // ================= SKILLS =================
            _infoCard(
              context,
              title: "My Skills",
              subtitle: "Skills extracted from your resume.",
              children: [
                profile.skills.isEmpty
                    ? Text(
                      "No skills found. Upload a resume to populate this section.",
                      style: TextStyle(fontSize: 12.sp),
                    )
                    : Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children:
                          profile.skills
                              .map(
                                (skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor: colorScheme.primary
                                      .withOpacity(0.1),
                                ),
                              )
                              .toList(),
                    ),
              ],
            ),

            SizedBox(height: 3.h),

            // ================= DANGER ZONE =================
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Danger Zone",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    "Permanently delete your account and all associated data.",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.red.shade700,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  ElevatedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Delete Account"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool showEdit = false,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
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
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showEdit)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // Edit bottom sheet later
                    },
                  ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 2.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          SizedBox(width: 3.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5.sp))),
        ],
      ),
    );
  }

  static void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
              "This action is irreversible. Are you sure you want to delete your account?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: call provider.deleteAccount()
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }
}
