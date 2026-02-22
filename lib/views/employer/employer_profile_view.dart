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

      appBar: AppBar(title: const Text("My Profile")),



      body: SingleChildScrollView(

        padding: EdgeInsets.all(4.w),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            _header(theme),

            SizedBox(height: 3.h),



            _profileCard(context, theme, profile),
            SizedBox(height: 3.h),



            _infoCard(

              context,

              title: "Personal Information",

              subtitle: "Your contact details",

              onEdit: () => _openEditSheet(context),

              children: [

                _row(Icons.email_outlined, profile.email),

                _row(

                  Icons.phone_outlined,

                  profile.phone.isEmpty ? "Not provided" : profile.phone,

                ),

              ],

            ),



            SizedBox(height: 2.5.h),



            _infoCard(

              context,

              title: "Company Information",

              subtitle: "Details about your company",

              children: [

                _row(

                  Icons.business_outlined,

                  profile.companyName.isEmpty

                      ? "Not provided"

                      : profile.companyName,

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

        "My Profile",

        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),

      ),

      Text(

        "View and manage your personal information.",

        style: TextStyle(

          fontSize: 12.5.sp,

          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),

        ),

      ),

    ],

  );



  Widget _profileCard(BuildContext context, ThemeData theme, EmployerProfileModel profile) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
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
                          profile.name.isNotEmpty ? profile.name[0] : "?",
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
            profile.name,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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

                      fontSize: 14.sp,

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



  Widget _row(IconData icon, String text) => Padding(

    padding: EdgeInsets.only(bottom: 1.2.h),

    child: Row(

      children: [

        Icon(icon, size: 18, color: Colors.grey),

        SizedBox(width: 3.w),

        Expanded(child: Text(text, style: TextStyle(fontSize: 12.5.sp))),

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

            fontSize: 15.sp,

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

    showDialog(

      context: context,

      builder:

          (_) => AlertDialog(

            title: const Text("Delete Account"),

            content: const Text("This action cannot be undone."),

            actions: [

              TextButton(

                onPressed: () => Navigator.pop(context),

                child: const Text("Cancel"),

              ),

              ElevatedButton(

                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                onPressed: () {

                  context.read<EmployerProfileProvider>().deleteAccount();

                  Navigator.pop(context);

                },

                child: const Text("Delete"),

              ),

            ],

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

  late TextEditingController nameCtrl;

  late TextEditingController phoneCtrl;

  late TextEditingController companyCtrl;



  @override

  void initState() {

    final profile = context.read<EmployerProfileProvider>().profile;

    nameCtrl = TextEditingController(text: profile.name);

    phoneCtrl = TextEditingController(text: profile.phone);

    companyCtrl = TextEditingController(text: profile.companyName);

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

            "Edit Profile",

            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),

          ),

          SizedBox(height: 2.h),



          TextField(

            controller: nameCtrl,

            decoration: const InputDecoration(labelText: "Name"),

          ),

          TextField(

            controller: phoneCtrl,

            decoration: const InputDecoration(labelText: "Phone"),

          ),

          TextField(

            controller: companyCtrl,

            decoration: const InputDecoration(labelText: "Company"),

          ),



          SizedBox(height: 2.h),



          ElevatedButton(

            onPressed: () {

              context.read<EmployerProfileProvider>().updateProfile(

                name: nameCtrl.text,

                phone: phoneCtrl.text,

                companyName: companyCtrl.text,

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

