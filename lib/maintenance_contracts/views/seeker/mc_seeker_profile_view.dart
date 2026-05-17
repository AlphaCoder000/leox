import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/mc_seeker_auth_controller.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import '../../models/mc_seeker_model.dart';
import '../../models/mc_review_model.dart';

class McSeekerProfileView extends StatefulWidget {
  const McSeekerProfileView({super.key});

  @override
  State<McSeekerProfileView> createState() => _McSeekerProfileViewState();
}

class _McSeekerProfileViewState extends State<McSeekerProfileView> {
  String? selectedServiceId;
  String? selectedServiceTitle;
  
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  final _serviceIdController = TextEditingController();

  @override
  void dispose() {
    _ratingController.dispose();
    _commentController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize with empty values
    selectedServiceId = null;
    selectedServiceTitle = null;
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      final authController = context.read<McSeekerAuthController>();
      final seekerId = authController.currentSeeker?.id ?? '';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('maintenance_contracts/profiles/$seekerId');
        final file = File(pickedFile.path);
        final uploadTask = storageRef.putFile(file);
        
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        // Update Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('mc_seekers')
            .doc(seekerId)
            .update({'profilePicture': downloadUrl});
            
        // Refresh seeker data to sync with dashboard
        await authController.fetchSeekerProfile(seekerId);
        
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
        content: Text("Are you sure you want to sign out?", style: TextStyle(fontSize: 17.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<McSeekerAuthController>().logout();
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
    String password = '';
    bool obscurePassword = true;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text("Delete Account Permanently", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This action is irreversible. All your requests, reviews, profile data, and credentials will be permanently deleted.",
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Please enter your password to confirm:",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1.h),
                TextField(
                  obscureText: obscurePassword,
                  onChanged: (val) => setState(() => password = val),
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
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
                onPressed: password.trim().isNotEmpty
                    ? () async {
                        Navigator.pop(dialogContext);
                        
                        if (!context.mounted) return;
                        
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final authController = context.read<McSeekerAuthController>();
                        final error = await authController.deleteAccount(password.trim());
                        
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
    final seeker = context.watch<McSeekerAuthController>().currentSeeker;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => _pickImage(context),
            tooltip: 'Upload Profile Picture',
          ),
        ],
      ),
      body: seeker == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(context, theme, seeker),
                  SizedBox(height: 3.h),
                  _buildReviewsSection(context, theme),
                  SizedBox(height: 3.h),
                  _buildFeedbackForm(context, theme),
                  SizedBox(height: 3.h),
                  _buildLogoutSection(context, theme),
                  SizedBox(height: 3.h),
                  _buildDeleteAccountSection(context, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, McSeekerModel seeker) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    backgroundImage: seeker.profilePicture.isNotEmpty == true
                        ? NetworkImage(seeker.profilePicture)
                        : null,
                    child: seeker.userName.isNotEmpty
                        ? Text(
                            seeker.userName.substring(0, 1).toUpperCase(),
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
                        seeker.userName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        seeker.email,
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        seeker.phone,
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        seeker.address,
                        style: TextStyle(
                          fontSize: 17.sp,
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
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.logout),
              label: Text("Logout", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, ThemeData theme) {
    final dashboardController = context.watch<McSeekerDashboardController>();
    final reviews = dashboardController.myReviews;

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
                  "Reviews & Feedback",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            if (reviews.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 42.sp, color: Colors.grey[400]),
                    SizedBox(height: 1.h),
                    Text(
                      "No reviews yet",
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Complete services to leave reviews",
                      style: TextStyle(fontSize: 17.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...reviews.map((review) => _buildReviewItem(context, review)),
              SizedBox(height: 2.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, McReviewModel review) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(review.serviceTitle),
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
              child: Text(
                review.comment,
                style: TextStyle(fontSize: 17.sp, color: theme.textTheme.bodyMedium?.color, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm(BuildContext context, ThemeData theme) {
    final authController = context.watch<McSeekerAuthController>();
    final seeker = authController.currentSeeker;
    
    if (seeker == null) return const SizedBox();

    // Controllers and state variables are managed at the class level

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
                Icon(Icons.feedback_outlined, size: 22.sp, color: Color(0xFF0EA5E9)),
                SizedBox(width: 2.w),
                Text(
                  "Leave a Review",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              "Share your experience with completed services",
              style: TextStyle(fontSize: 17.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 2.h),
            Consumer<McSeekerDashboardController>(
              builder: (context, dashboardController, child) {
                final completedRequests = dashboardController.myRequests
                    .where((request) => request.status == 'completed')
                    .toList();
                
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  itemHeight: null,
                  decoration: InputDecoration(
                    labelText: "Select Completed Service",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.history),
                  ),
                  value: selectedServiceId,
                  items: completedRequests.isEmpty
                      ? [
                          DropdownMenuItem(
                            value: '',
                            child: Text("No completed services available"),
                          ),
                        ]
                      : completedRequests.map((request) {
                          // Look up the service title from allServices
                          final serviceList = dashboardController.allServices.where((s) => s.id == request.serviceId);
                          final title = serviceList.isNotEmpty ? serviceList.first.title : 'Service ${request.serviceId.substring(0, 5)}...';
                          
                          return DropdownMenuItem(
                            value: request.serviceId,
                            child: Text(
                              '$title - ${request.status.toUpperCase()}',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final serviceList = dashboardController.allServices.where((s) => s.id == value);
                      final title = serviceList.isNotEmpty ? serviceList.first.title : value;
                      
                      setState(() {
                        selectedServiceId = value;
                        selectedServiceTitle = title;
                        _serviceIdController.text = value;
                      });
                    }
                  },
                );
              },
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Rating (1-5)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.star_rate),
              ),
            ),
            const SizedBox(height: 1),
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Your Feedback",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.comment),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _submitFeedback(context, seeker),
                child: Text("Submit Review", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback(BuildContext context, McSeekerModel seeker) {
    if (_ratingController.text.trim().isEmpty ||
        _commentController.text.trim().isEmpty ||
        _serviceIdController.text.trim().isEmpty ||
        selectedServiceTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final serviceId = _serviceIdController.text.trim();
    final dashboardController = context.read<McSeekerDashboardController>();
    
    // Find the request to get the providerId
    String providerId = '';
    try {
      final request = dashboardController.myRequests.firstWhere((r) => r.serviceId == serviceId);
      providerId = request.providerId;
    } catch (e) {
      debugPrint("Could not find providerId for service: $serviceId");
    }

    final review = McReviewModel(
      id: '',
      seekerId: seeker.id,
      providerId: providerId,
      serviceId: serviceId,
      serviceTitle: selectedServiceTitle!,
      rating: double.tryParse(_ratingController.text.trim()) ?? 0.0,
      comment: _commentController.text.trim(),
      dateTime: DateTime.now(),
      seekerName: seeker.userName,
    );

    context.read<McSeekerDashboardController>().submitReview(review);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Review submitted successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _ratingController.clear();
    _commentController.clear();
    _serviceIdController.clear();
    setState(() {
      selectedServiceId = null;
      selectedServiceTitle = null;
    });
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
            style: TextStyle(fontSize: 17.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text("Delete Account", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

}
