import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/theme_povider.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../models/mc_provider_model.dart';

class McProviderProfileView extends StatelessWidget {
  const McProviderProfileView({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 3.w),
            Text("Logout", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Are you sure you want to sign out?", style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<McProviderAuthController>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/role-option', (route) => false);
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    String confirmationText = '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text("Delete Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("This action cannot be undone. All your details and services will be permanently deleted.", style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 1.5.h),
                Text('Please type "delete" to confirm:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 1.h),
                TextField(
                  onChanged: (val) => setState(() => confirmationText = val),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: confirmationText.trim().toLowerCase() == 'delete'
                    ? () async {
                        Navigator.pop(dialogContext);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final providerRef = FirebaseFirestore.instance.collection('mc_providers').doc(context.read<McProviderAuthController>().currentProvider!.id);
                        await providerRef.delete();
                        
                        await context.read<McProviderAuthController>().logout();
                        
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil('/role-option', (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account successfully deleted.")));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<McProviderAuthController>().currentProvider;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: provider == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(theme, provider),
                  SizedBox(height: 3.h),
                  _buildThemeSelector(themeProvider, theme),
                  SizedBox(height: 3.h),
                  _buildDangerZone(context, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, McProviderModel provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
              child: Text(
                provider.companyName.isNotEmpty ? provider.companyName.substring(0, 1).toUpperCase() : "?",
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0EA5E9)),
              ),
            ),
            SizedBox(height: 2.h),
            Text(provider.companyName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 0.5.h),
            Text(provider.email, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            SizedBox(height: 2.h),
            const Divider(),
            SizedBox(height: 1.h),
            _infoRow(Icons.phone_outlined, provider.phone),
            SizedBox(height: 1.h),
            _infoRow(Icons.location_on_outlined, provider.location),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 3.w),
        Expanded(child: Text(text, style: TextStyle(fontSize: 15.sp))),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("App Appearance", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            RadioListTile<ThemeMode>(
              title: Text("Light Mode", style: TextStyle(fontSize: 14.sp)),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (v) => themeProvider.setLight(),
            ),
            RadioListTile<ThemeMode>(
              title: Text("Dark Mode", style: TextStyle(fontSize: 14.sp)),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (v) => themeProvider.setDark(),
            ),
            RadioListTile<ThemeMode>(
              title: Text("System Default", style: TextStyle(fontSize: 14.sp)),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (v) => themeProvider.setSystem(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        color: Colors.red.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 2.w),
              Text("Account Options", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          SizedBox(height: 2.h),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.logout),
            label: Text("Logout", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            onPressed: () => _confirmLogout(context),
          ),
          SizedBox(height: 1.5.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text("Delete Account", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}
