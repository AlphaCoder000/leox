import 'package:flutter/material.dart';
import 'package:leox/maintenance_contracts/controllers/mc_provider_dashboard_controller.dart';
import 'package:leox/maintenance_contracts/models/mc_review_model.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../models/mc_provider_model.dart';

class McProviderProfileView extends StatefulWidget {
  const McProviderProfileView({super.key});

  @override
  State<McProviderProfileView> createState() => _McProviderProfileViewState();
}

class _McProviderProfileViewState extends State<McProviderProfileView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authController = context.read<McProviderAuthController>();
    final user = FirebaseAuth.instance.currentUser;
    if (authController.currentProvider == null && user != null) {
      authController.fetchProviderProfile(user.uid);
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      final authController = context.read<McProviderAuthController>();
      final providerId = authController.currentProvider?.id ?? '';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('maintenance_contracts/profiles/$providerId');
        final file = File(pickedFile.path);
        final uploadTask = storageRef.putFile(file);
        
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        // Update Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('mc_providers')
            .doc(providerId)
            .update({'profilePicture': downloadUrl});
        
        // Refresh provider data to sync with dashboard
        await authController.fetchProviderProfile(providerId);
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile picture: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 3.w),
            Text("Logout", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Are you sure you want to sign out?", style: TextStyle(fontSize: 16.sp)),
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
    String confirmationInput = '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text("Delete Account Permanently", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "This action is irreversible. All your services, requests, reviews, profile data, and credentials will be permanently deleted.",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Please type \"DELETE\" in all capital letters to confirm:",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    onChanged: (val) => setState(() => confirmationInput = val),
                    decoration: const InputDecoration(
                      hintText: "Type DELETE",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: confirmationInput == "DELETE"
                    ? () async {
                        Navigator.pop(dialogContext);
                        
                        if (!context.mounted) return;
                        
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final authController = context.read<McProviderAuthController>();
                        final error = await authController.deleteAccount();
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Dismiss loading dialog
                          
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil('/role-option', (route) => false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Account and all associated records successfully deleted permanently."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: const Text("Permanently Delete Account"),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          if (provider != null)
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => _pickImage(context),
              tooltip: 'Upload Profile Picture',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider == null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "No Provider Profile",
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  "You are signed in but do not have an active Provider profile.",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              _buildProfileCard(context, theme, provider),
              SizedBox(height: 3.h),
              _buildReviewsSection(context, theme),
            ],
            SizedBox(height: 3.h),
            _buildLogoutSection(context, theme),
            SizedBox(height: 3.h),
            _buildDeleteAccountSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, McProviderModel? provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    backgroundImage: provider?.profilePicture != null && provider!.profilePicture.isNotEmpty
                        ? NetworkImage(provider.profilePicture)
                        : null,
                    child: provider?.companyName != null && provider!.companyName.isNotEmpty
                        ? Text(
                            provider.companyName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider?.companyName ?? 'Provider',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        provider?.email ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        provider?.phone ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        provider?.location ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Rating: ${provider?.rating ?? 0.0}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0EA5E9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: theme.colorScheme.primary,
                    onPressed: () => _openEditSheet(context, provider),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.reviews_outlined, size: 22.sp, color: Color(0xFF0EA5E9)),
                SizedBox(width: 2.w),
                Text(
                  "Customer Reviews",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<McProviderDashboardController>(
              builder: (context, dashboardController, _) {
                final reviews = dashboardController.providerReviews;
                
                if (reviews.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 42.sp, color: Colors.grey[400]),
                        SizedBox(height: 1.h),
                        Text(
                          "Reviews will appear here after service completion",
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Customers can rate your services",
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: reviews.map((review) => _buildReviewItem(context, review, theme)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.logout_rounded, color: Colors.redAccent),
                SizedBox(width: 2.w),
                Text("Session", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 2.h),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.logout),
              label: Text("Logout", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        color: Colors.red.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 2.w),
              Text("Danger Zone", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            "Permanently delete your account and all associated data. This action cannot be undone.",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text("Delete Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
}

  Widget _buildReviewItem(BuildContext context, McReviewModel review, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("${review.serviceTitle} by ${review.seekerName}"),
            content: SingleChildScrollView(
              child: Text(review.comment, style: TextStyle(fontSize: 16.sp)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.serviceTitle,
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            Icons.star,
                            color: index < review.rating ? const Color(0xFFFFD700) : Colors.grey[300],
                            size: 18.sp,
                          )),
                        
                        SizedBox(width: 1.w),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 17.sp, color: theme.textTheme.bodyMedium?.color),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          review.dateTime.toString().split(' ')[0],
                          style: TextStyle(fontSize: 17.sp, color: Colors.grey[600]),
                        ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (review.seekerName.isNotEmpty) ...[
                    Text(
                      "Review by: ${review.seekerName}",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0EA5E9)),
                    ),
                    SizedBox(height: 0.5.h),
                  ],
                  Text(
                    review.comment,
                    style: TextStyle(fontSize: 17.sp, color: theme.textTheme.bodyMedium?.color, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, McProviderModel provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProviderProfileSheet(provider: provider),
    );
  }
}

class _EditProviderProfileSheet extends StatefulWidget {
  final McProviderModel provider;
  const _EditProviderProfileSheet({required this.provider});

  @override
  State<_EditProviderProfileSheet> createState() => _EditProviderProfileSheetState();
}

class _EditProviderProfileSheetState extends State<_EditProviderProfileSheet> {
  late TextEditingController _companyNameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.provider.companyName);
    _phoneController = TextEditingController(text: widget.provider.phone);
    _locationController = TextEditingController(text: widget.provider.location);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              fontSize: 23.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _companyNameController,
            decoration: InputDecoration(
              labelText: "Company Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 1.5.h),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: "Location",
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
                child: Consumer<McProviderAuthController>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final name = _companyNameController.text.trim();
                              final phone = _phoneController.text.trim();
                              final location = _locationController.text.trim();
                              if (name.isNotEmpty && phone.isNotEmpty && location.isNotEmpty) {
                                await auth.updateProviderProfile(
                                  companyName: name,
                                  phone: phone,
                                  location: location,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile updated successfully')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All fields are required')),
                                );
                              }
                            },
                      child: const Text("Save"),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

