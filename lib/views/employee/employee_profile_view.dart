import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leox/models/employee_profile_model.dart';
import 'package:leox/providers/employee_providers/employee_profile_provider.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/utils/error_handler_ui.dart';
import 'package:leox/widgets/employee_drawer.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final authProvider = context.read<EmployeeAuthProvider>();

    if (!authProvider.isLoggedIn) {
      debugPrint('[EmployeeProfile] Session invalid, logging out');
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/role-option', (route) => false);
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
                      fontSize: 23.sp,// Updated from 16.sp to 21.sp
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
                                        
                                        final currentProfile = provider.profile;
                                        if (currentProfile != null) {
                                          final updatedProfile = EmployeeProfileModel(
                                            id: currentProfile.id,
                                            email: currentProfile.email,
                                            firstName: _firstNameController.text.trim(),
                                            lastName: _lastNameController.text.trim(),
                                            headline: _headlineController.text.trim(),
                                            bio: _bioController.text.trim(),
                                            skills: currentProfile.skills,
                                            resumeUrl: currentProfile.resumeUrl,
                                            createdAt: currentProfile.createdAt,
                                            updatedAt: DateTime.now(),
                                          );
                                          
                                          await provider.updateProfile(updatedProfile);
                                        }

                                        if (scaffoldContext.mounted) {
                                          if (provider.errorMessage == null) {
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
                                                final context = scaffoldContext;
                                                if (!context.mounted) return;
                                                
                                                final currentProfile = provider.profile;
                                                if (currentProfile != null) {
                                                  final updatedProfile = EmployeeProfileModel(
                                                    id: currentProfile.id,
                                                    email: currentProfile.email,
                                                    firstName: _firstNameController.text.trim(),
                                                    lastName: _lastNameController.text.trim(),
                                                    headline: _headlineController.text.trim(),
                                                    bio: _bioController.text.trim(),
                                                    skills: currentProfile.skills,
                                                    resumeUrl: currentProfile.resumeUrl,
                                                    createdAt: currentProfile.createdAt,
                                                    updatedAt: DateTime.now(),
                                                  );
                                                  
                                                  await provider.updateProfile(updatedProfile);
                                                }
                                                if (provider.errorMessage == null) {
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ErrorHandlerUI.showSuccessSnackbar(
                                                      context,
                                                      'Profile updated successfully',
                                                    );
                                                  }
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      final success = await context
          .read<EmployeeProfileProvider>()
          .uploadProfilePicture(pickedFile);

      if (mounted) {
        if (success) {
          ErrorHandlerUI.showSuccessSnackbar(
            context,
            'Profile picture updated successfully',
          );
        } else {
          ErrorHandlerUI.showErrorSnackbar(
            context,
            'Failed to update profile picture',
          );
        }
      }
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && mounted) {
      final file = result.files.single;
      debugPrint('[EmployeeProfileView] Selected file: ${file.name}, path: ${file.path}, size: ${file.size}');
      
      if (file.path == null) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          'File path is null. Please try again.',
        );
        return;
      }
      
      final success = await context
          .read<EmployeeProfileProvider>()
          .uploadResume(file);

      if (mounted) {
        if (success) {
          ErrorHandlerUI.showSuccessSnackbar(
            context,
            'Resume uploaded successfully',
          );
        } else {
          ErrorHandlerUI.showErrorSnackbar(
            context,
            'Failed to upload resume',
          );
        }
      }
    }
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
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.profile),
      appBar: AppBar(title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
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
                

                SizedBox(height: 3.h),

                // ================= PROFILE CARD =================
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                backgroundImage:
                                    (profile.profilePicture
                                            .isNotEmpty)
                                        ? NetworkImage(profile.profilePicture)
                                        : null,
                                child:
                                    (profile.profilePicture.isEmpty)
                                        ? Text(
                                          (profile.firstName).isNotEmpty
                                              ? profile.firstName[0]
                                                  .toUpperCase()
                                              : "?",
                                          style: TextStyle(
                                            fontSize: 32.sp, fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        )
                                        : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: colorScheme.primary,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ],
                            ),
                          ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "${profile.firstName} ${profile.lastName}",
                          style: TextStyle(
                            fontSize: 17.sp, fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (profile.headline.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 0.5.h),
                            child: Text(
                              profile.headline,
                              style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                

                SizedBox(height: 1.h),

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
                    if (profile.bio.isNotEmpty)
                      _infoRow(Icons.article_outlined, profile.bio),
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
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                    subtitle: "Upload a resume to auto-fill your profile information.",
                    children: [
                      if (profile.resumeUrl.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.description, color: colorScheme.primary),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                "Resume uploaded",
                                style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final url = Uri.parse(profile.resumeUrl);
                                try {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } catch (_) {
                                  if (context.mounted) {
                                    ErrorHandlerUI.showErrorSnackbar(
                                        context, "Could not open resume format.");
                                  }
                                }
                              },
                              child: const Text("View"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                context.read<EmployeeProfileProvider>().deleteResume();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                      OutlinedButton.icon(
                        onPressed: _pickResume,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: Text(
                          profile.resumeUrl.isEmpty
                              ? "Upload Resume"
                              : "Update Resume",
                        ),
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
                          fontSize: 18.sp, fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        "Permanently delete your account and all associated data.",
                        style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.normal,
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
                      fontSize: 17.sp, fontWeight: FontWeight.w600,
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
                fontSize: 16.sp, fontWeight: FontWeight.normal,
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
          Expanded(child: Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  static void _confirmDelete(BuildContext context) {
    String confirmationText = '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text("Delete Account"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("This action cannot be undone. All your applications and data will be permanently deleted."),
                SizedBox(height: 1.5.h),
                const Text('Please type "delete" to confirm:'),
                SizedBox(height: 1.h),
                TextField(
                  onChanged: (val) {
                    setState(() {
                      confirmationText = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "delete",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: confirmationText.trim().toLowerCase() == 'delete'
                    ? () async {
                        Navigator.pop(dialogContext);
                        
                        // Show a loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final provider = context.read<EmployeeProfileProvider>();
                        bool success = await provider.deleteAccount();
                        
                        // Using a new context if needed or mounted check
                        if (context.mounted) {
                          Navigator.pop(context); // close loading
                          if (success) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/role-option', (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Account deleted successfully')),
                            );
                          } else {
                            ErrorHandlerUI.showErrorSnackbar(
                              context,
                              provider.errorMessage ?? 'Failed to delete account',
                            );
                          }
                        }
                      }
                    : null,
                child: const Text("Delete"),
              ),
            ],
          );
        },
      ),
    );
  }
}


