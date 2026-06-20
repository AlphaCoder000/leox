import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import '../../controllers/mc_seeker_auth_controller.dart';
import '../../models/mc_service_model.dart';
import '../../models/mc_request_model.dart';
import 'package:leox/widgets/custom_popup.dart';

class McServiceDetailsView extends StatefulWidget {
  final McServiceModel service;

  const McServiceDetailsView({super.key, required this.service});

  @override
  State<McServiceDetailsView> createState() => _McServiceDetailsViewState();
}

class _McServiceDetailsViewState extends State<McServiceDetailsView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryBlue = const Color(0xFF0EA5E9);
    final textOnSurface = theme.colorScheme.onSurface;
    final secondaryText = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Details"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textOnSurface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: isDark ? 0.04 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label_outline_rounded,
                              size: 16.sp,
                              color: primaryBlue,
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              widget.service.category,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.service.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: textOnSurface,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Divider(color: theme.dividerColor.withValues(alpha: 0.5), height: 1),
                      SizedBox(height: 2.h),
                      // Contractor Profile Row
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('mc_providers').doc(widget.service.providerId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
                            final data = snapshot.data!.data() as Map<String, dynamic>?;
                            final companyName = data?['companyName'] ?? 'Unknown Contractor';
                            final companyAddress = data?['address'] ?? '';
                            return Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.5.w),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.business_rounded,
                                    color: primaryBlue,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Contractor Provider",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryText,
                                        ),
                                      ),
                                      SizedBox(height: 0.4.h),
                                      Text(
                                        companyName,
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold,
                                          color: textOnSurface,
                                        ),
                                      ),
                                      if (companyAddress.isNotEmpty) ...[
                                        SizedBox(height: 0.4.h),
                                        Text(
                                          companyAddress,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: secondaryText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Estimated Price Dashboard Card
              Container(
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: primaryBlue,
                            size: 18.sp,
                          ),
                          SizedBox(width: 2.5.w),
                          Text(
                            "Estimated Budget",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: textOnSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.service.priceRange.isNotEmpty ? widget.service.priceRange : "₹${widget.service.price}",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Description Section
              _buildSectionHeader("Service Description", Icons.description_outlined, theme),
              SizedBox(height: 1.5.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.5.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  widget.service.description,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 1.0),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Price Justification Section
              if (widget.service.priceJustification.isNotEmpty) ...[
                _buildSectionHeader("Pricing Breakdown & Justification", Icons.info_outline_rounded, theme),
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    widget.service.priceJustification,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 1.0),
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),
              ],

              // Custom Request Message input
              _buildSectionHeader("Enquiry", Icons.chat_bubble_outline_rounded, theme),
              SizedBox(height: 1.5.h),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 16.sp, color: textOnSurface),
                  decoration: InputDecoration(
                    hintText: "Add Specific Requirements, Requests, Timing Preferences, Questions and Queries here...",
                    hintStyle: TextStyle(fontSize: 16.sp, color: secondaryText),
                    contentPadding: EdgeInsets.all(4.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: primaryBlue.withValues(alpha: 0.3),
                  ),
                  onPressed: () async {
                    final seeker = context.read<McSeekerAuthController>().currentSeeker;
                    if (seeker != null) {
                      final newRequest = McRequestModel(
                        id: '',
                        seekerId: seeker.id,
                        providerId: widget.service.providerId,
                        serviceId: widget.service.id,
                        status: 'pending',
                        dateTime: DateTime.now(),
                        seekerName: seeker.userName,
                        seekerPhone: seeker.phone,
                        seekerAddress: seeker.address,
                        message: _messageController.text.trim(),
                      );
                      context.read<McSeekerDashboardController>().createRequest(newRequest);

                      await CustomPopup.show(
                        context,
                        type: CustomPopupType.success,
                        title: 'Enquiry Sent!',
                        message: 'Your enquiry for "${widget.service.title}" has been placed successfully and is pending provider approval.',
                        buttonLabel: 'View Enquiries',
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt, size: 20.sp, color: Colors.white),
                      SizedBox(width: 2.w),
                      Text(
                        "Send Enquiry",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15.sp,
          color: const Color(0xFF0EA5E9),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
