import 'package:flutter/material.dart';
import 'package:leox/models/employee_profile_model.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/providers/employee_providers/employee_profile_provider.dart';
import 'package:leox/utils/route_guard.dart';
import 'package:leox/utils/error_handler_ui.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EmployeeProfileView extends StatefulWidget {
  const EmployeeProfileView({super.key});

  @override
  State<EmployeeProfileView> createState() => _EmployeeProfileViewState();
}

class _EmployeeProfileViewState extends State<EmployeeProfileView>
    with WidgetsBindingObserver {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _headlineController;
  late TextEditingController _bioController;
  late TextEditingController _skillController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _headlineController = TextEditingController();
    _bioController = TextEditingController();
    _skillController = TextEditingController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Validate session when app resumes from background
    if (state == AppLifecycleState.resumed) {
      debugPrint('[EmployeeProfile] App resumed, validating session...');
      _validateSession();
    }
  }

  Future<void> _validateSession() async {
    if (!mounted) return;

    final isValid = await RouteGuard.validateSession(context);
    if (!isValid && mounted) {
      debugPrint('[EmployeeProfile] Session validation failed, logging out');
      final authProvider = context.read<EmployeeAuthProvider>();
      await authProvider.logout();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/role-option', (route) => false);

        ErrorHandlerUI.showWarningSnackbar(
          context,
          'Session expired, please login again',
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load profile data on first build
    final profileProvider = context.read<EmployeeProfileProvider>();
    if ((profileProvider.profile?.id ?? '').isEmpty) {
      profileProvider.loadProfile();
    }
  }

  void _showEditBottomSheet(BuildContext context) {
    final profileProvider = context.read<EmployeeProfileProvider>();
    final profile = profileProvider.profile;

    // Initialize with current values
    _firstNameController.text = profile?.firstName ?? '';
    _lastNameController.text = profile?.lastName ?? '';
    _headlineController.text = profile?.headline ?? '';
    _bioController.text = profile?.bio ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 4.w,
                right: 4.w,
                top: 4.w,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      hintText: "Enter your first name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      hintText: "Enter your last name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  TextField(
                    controller: _headlineController,
                    decoration: InputDecoration(
                      labelText: "Headline",
                      hintText: "e.g., Flutter Developer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Bio",
                      hintText: "Tell us about yourself...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Consumer<EmployeeProfileProvider>(
                          builder: (context, provider, _) {
                            return ElevatedButton(
                              onPressed:
                                  provider.isLoading
                                      ? null
                                      : () async {
                                        // Capture context before async operation
                                        final scaffoldContext = context;
                                        
                                        final success = await provider
                                            .updateProfile(
                                              firstName:
                                                  _firstNameController.text
                                                      .trim(),
                                              lastName:
                                                  _lastNameController.text
                                                      .trim(),
                                              headline:
                                                  _headlineController.text
                                                      .trim(),
                                              bio: _bioController.text.trim(),
                                            );

                                        if (mounted) {
                                          if (success) {
                                            Navigator.pop(scaffoldContext);
                                            ErrorHandlerUI.showSuccessSnackbar(
                                              scaffoldContext,
                                              'Profile updated successfully',
                                            );
                                          } else {
                                            ErrorHandlerUI.showErrorSnackbar(
                                              scaffoldContext,
                                              provider.errorMessage ??
                                                  'Unknown error',
                                              onRetry: () async {
                                                final retrySuccess =
                                                    await provider.updateProfile(
                                                      firstName:
                                                          _firstNameController
                                                              .text
                                                              .trim(),
                                                      lastName:
                                                          _lastNameController
                                                              .text
                                                              .trim(),
                                                      headline:
                                                          _headlineController
                                                              .text
                                                              .trim(),
                                                      bio:
                                                          _bioController.text
                                                              .trim(),
                                                    );
                                                if (!retrySuccess && mounted) {
                                                  ErrorHandlerUI.showErrorSnackbar(
                                                    scaffoldContext,
                                                    provider.errorMessage ??
                                                        'Unknown error',
                                                  );
                                                }
                                              },
                                            );
                                          }
                                        }
                                      },
                              child:
                                  provider.isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text("Save"),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    _skillController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Skill"),
          content: TextField(
            controller: _skillController,
            decoration: InputDecoration(
              hintText: "e.g., Flutter, Dart, Firebase",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_skillController.text.trim().isNotEmpty) {
                  context.read<EmployeeProfileProvider>().addSkill(
                    _skillController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.dashboard),
      appBar: AppBar(title: const Text("My Profile")),
      body: Consumer<EmployeeProfileProvider>(
        builder: (context, profileProvider, _) {
          // Show loading spinner
          if (profileProvider.isLoading &&
              (profileProvider.profile?.id ?? '').isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final profile =
              profileProvider.profile ?? EmployeeProfileModel.empty();
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "View and manage your personal information.",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            (profile.firstName).isNotEmpty
                                ? profile.firstName[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          "${profile.firstName} ${profile.lastName}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((profile.headline ?? '').isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 0.5.h),
                            child: Text(
                              profile.headline ?? '',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
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
                  onEdit: () => _showEditBottomSheet(context),
                  children: [
                    _infoRow(
                      Icons.person_outline,
                      "${profile.firstName} ${profile.lastName}",
                    ),
                    _infoRow(Icons.email_outlined, profile.email),
                    _infoRow(
                      Icons.phone_outlined,
                      (profile.phone ?? '').isEmpty
                          ? "Not provided"
                          : profile.phone ?? '',
                    ),
                    if ((profile.bio ?? '').isNotEmpty)
                      _infoRow(Icons.article_outlined, profile.bio ?? ''),
                  ],
                ),

                SizedBox(height: 2.5.h),

                // ================= SKILLS =================
                _infoCard(
                  context,
                  title: "My Skills",
                  subtitle: "Manage your professional skills.",
                  onEdit: () => _showAddSkillDialog(context),
                  showEdit: true,
                  children: [
                    if (profile.skills.isEmpty)
                      Text(
                        "No skills added yet. Click edit to add some.",
                        style: TextStyle(fontSize: 12.sp),
                      )
                    else
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children:
                            profile.skills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                backgroundColor: colorScheme.primary
                                    .withValues(alpha: 0.1),
                                onDeleted: () {
                                  profileProvider.removeSkill(skill);
                                },
                              );
                            }).toList(),
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
                      (profile.resumeUrl ?? '').isEmpty
                          ? "You have not uploaded a resume yet."
                          : "Resume: ${(profile.resumeUrl ?? '').split('/').last}",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 1.5.h),
                    OutlinedButton.icon(
                      onPressed: () {
                        ErrorHandlerUI.showInfoSnackbar(
                          context,
                          "Resume upload feature coming soon",
                        );
                      },
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text("Upload & Parse Resume"),
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
          );
        },
      ),
    );
  }

  // ================= HELPERS =================

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool showEdit = false,
    VoidCallback? onEdit,
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
                    onPressed: onEdit,
                  ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
