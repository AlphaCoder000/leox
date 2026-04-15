import 'package:flutter/material.dart';

import 'package:leox/constants/employer_drawer_item.dart';

import 'package:leox/providers/employer_profile_provider.dart';

import 'package:leox/widgets/employer_drawer.dart';

import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';



import 'package:image_picker/image_picker.dart';
import 'package:leox/models/employer_profile_model.dart';

class EmployerProfileView extends StatelessWidget {

  const EmployerProfileView({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      await context.read<EmployerProfileProvider>().uploadProfilePicture(pickedFile);
    }
  }



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final profile = context.watch<EmployerProfileProvider>().profile;



    return Scaffold(

      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.profile),

      appBar: AppBar(title: const Text("My Profile", style: TextStyle(fontSize: 20),)),



      body: SingleChildScrollView(

        padding: EdgeInsets.all(2.w),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            _header(theme),

            SizedBox(height: 2.h),



            _profileCard(context, theme, profile),
            SizedBox(height: 3.h),



            _infoCard(
              context,
              title: "Company Information",
              subtitle: "Details about your company",
              onEdit: () => _openEditSheet(context),
              children: [
                _row(Icons.email_outlined, profile.email),
                _row(
                  Icons.business_outlined,
                  profile.companyName.isEmpty
                      ? "Not provided"
                      : profile.companyName,
                ),
                _row(
                  Icons.phone_outlined,
                  (profile.contactNumber ?? '').isEmpty
                      ? "Not provided"
                      : profile.contactNumber!,
                ),
                _row(
                  Icons.location_on_outlined,
                  (profile.address ?? '').isEmpty
                      ? "Not provided"
                      : profile.address!,
                ),
                _row(
                  Icons.link_outlined,
                  (profile.linkedin ?? '').isEmpty
                      ? "Not provided"
                      : profile.linkedin!,
                ),
              ],
            ),



            SizedBox(height: 3.h),



            _dangerZone(context),

          ],

        ),

      ),

    );

  }



  // ---------------- UI SECTIONS ----------------



  Widget _header(ThemeData theme) => Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      Text(

        "View and manage your personal information.",

        style: TextStyle(

          fontSize: 16.sp,

          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),

        ),

      ),

    ],

  );



  Widget _profileCard(BuildContext context, ThemeData theme, EmployerProfileModel profile) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  backgroundImage: (profile.profilePicture ?? '').isNotEmpty
                      ? NetworkImage(profile.profilePicture!)
                      : null,
                  child: (profile.profilePicture ?? '').isEmpty
                      ? Text(
                          profile.companyName.isNotEmpty ? profile.companyName[0] : "?",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            profile.companyName.isNotEmpty ? profile.companyName : "Company Name",
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );



  Widget _infoCard(

    BuildContext context, {

    required String title,

    required String subtitle,

    VoidCallback? onEdit,

    required List<Widget> children,

  }) {

    final theme = Theme.of(context);



    return Card(

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

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

                      fontSize: 17.sp,

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ),

                if (onEdit != null)

                  IconButton(

                    icon: const Icon(Icons.edit_outlined),

                    onPressed: onEdit,

                  ),

              ],

            ),

            Text(

              subtitle,

              style: TextStyle(

                fontSize: 14.sp,

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



  Widget _row(IconData icon, String text) => Padding(

    padding: EdgeInsets.only(bottom: 1.2.h),

    child: Row(

      children: [

        Icon(icon, size: 18, color: Colors.grey),

        SizedBox(width: 3.w),

        Expanded(child: Text(text, style: TextStyle(fontSize: 16.sp))),

      ],

    ),

  );



  Widget _dangerZone(BuildContext context) => Container(

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

            fontSize: 16.sp,

            fontWeight: FontWeight.bold,

            color: Colors.red,

          ),

        ),

        SizedBox(height: 1.h),

        ElevatedButton.icon(

          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),

          icon: const Icon(Icons.delete_outline),

          label: const Text("Delete Account"),

          onPressed: () => _confirmDelete(context),

        ),

      ],

    ),

  );



  // ---------------- ACTIONS ----------------



  void _openEditSheet(BuildContext context) {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (_) => const _EditProfileSheet(),

    );

  }



  void _confirmDelete(BuildContext context) {
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
                const Text("This action cannot be undone. All your jobs and data will be permanently deleted."),
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
                        
                        final provider = context.read<EmployerProfileProvider>();
                        bool success = await provider.deleteAccount();
                        
                        if (context.mounted) {
                          Navigator.pop(context); // close loading
                          if (success) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/role-option', (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Account deleted successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage ?? 'Failed to delete account')),
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



class _EditProfileSheet extends StatefulWidget {

  const _EditProfileSheet();



  @override

  State<_EditProfileSheet> createState() => _EditProfileSheetState();

}



class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController companyCtrl;
  late TextEditingController contactNumberCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController linkedinCtrl;

  @override
  void initState() {
    final profile = context.read<EmployerProfileProvider>().profile;
    companyCtrl = TextEditingController(text: profile.companyName);
    contactNumberCtrl = TextEditingController(text: profile.contactNumber);
    addressCtrl = TextEditingController(text: profile.address);
    linkedinCtrl = TextEditingController(text: profile.linkedin);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        4.w,
        4.w,
        4.w,
        MediaQuery.of(context).viewInsets.bottom + 2.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edit Company Information",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2.h),

          TextField(
            controller: companyCtrl,
            decoration: const InputDecoration(labelText: "Company Name"),
          ),
          TextField(
            controller: contactNumberCtrl,
            decoration: const InputDecoration(labelText: "Contact Number"),
          ),
          TextField(
            controller: addressCtrl,
            decoration: const InputDecoration(labelText: "Address"),
          ),
          TextField(
            controller: linkedinCtrl,
            decoration: const InputDecoration(labelText: "LinkedIn (Optional)"),
          ),

          SizedBox(height: 2.h),

          ElevatedButton(
            onPressed: () {
              context.read<EmployerProfileProvider>().updateProfile(
                companyName: companyCtrl.text.trim(),
                contactNumber: contactNumberCtrl.text.trim(),
                address: addressCtrl.text.trim(),
                linkedin: linkedinCtrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

}

