import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import '../../models/mc_request_model.dart';

class McSeekerBookingsView extends StatelessWidget {
  const McSeekerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McSeekerDashboardController>();

    if (dashboardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = List<McRequestModel>.from(dashboardController.myRequests)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      body: requests.isEmpty
          ? _buildEmptyState(context)
          : _buildBookingsList(requests, context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 50.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "No Bookings Yet",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Your service bookings will appear here.",
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List requests, BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(4.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final request = requests[index];
                return _buildBookingCard(request, theme, context);
              },
              childCount: requests.length,
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 5.h)),
      ],
    );
  }

  Widget _buildBookingCard(McRequestModel request, ThemeData theme, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('mc_providers').doc(request.providerId).get(),
      builder: (context, snapshot) {
        String companyName = "Loading Provider...";
        String providerPhone = "";
        String providerEmail = "";
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          companyName = data?['companyName'] ?? 'Unknown Provider';
          providerPhone = data?['phone'] ?? '';
          providerEmail = data?['email'] ?? '';
        }

        final isRevealed = request.status == 'accepted' || request.status == 'completed';

        return GestureDetector(
          onTap: () => _showBookingDetailSheet(context, request, companyName, providerPhone, providerEmail),
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _getStatusColor(request.status).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(request.status),
                          color: _getStatusColor(request.status),
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Service Booking",
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          request.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _getStatusColor(request.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                      SizedBox(width: 1.5.w),
                      Text(
                        "Booked on: ${request.dateTime.toLocal().toString().split(' ')[0]}",
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  if (request.message.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Text(
                      "Your Message",
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      request.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (isRevealed) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contact_phone_outlined, size: 15.sp, color: const Color(0xFF0EA5E9)),
                              SizedBox(width: 2.w),
                              Text(
                                "Provider Contact Details",
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0EA5E9),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                           GestureDetector(
                            onTap: providerPhone.isNotEmpty ? () => launchUrl(Uri.parse('tel:$providerPhone')) : null,
                            child: Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 14.sp, color: providerPhone.isNotEmpty ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                SizedBox(width: 2.w),
                                Text(
                                  providerPhone.isNotEmpty ? providerPhone : "Not Provided",
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: providerPhone.isNotEmpty ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                    decoration: providerPhone.isNotEmpty ? TextDecoration.underline : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          GestureDetector(
                            onTap: providerEmail.isNotEmpty ? () => launchUrl(Uri.parse('mailto:$providerEmail')) : null,
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined, size: 14.sp, color: providerEmail.isNotEmpty ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                SizedBox(width: 2.w),
                                Text(
                                  providerEmail.isNotEmpty ? providerEmail : "Not Provided",
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: providerEmail.isNotEmpty ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                    decoration: providerEmail.isNotEmpty ? TextDecoration.underline : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'accepted':
        return Icons.check_circle;
      case 'completed':
        return Icons.task_alt;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showBookingDetailSheet(BuildContext context, McRequestModel request, String companyName, String phone, String email) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(request.status),
                        color: _getStatusColor(request.status),
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        "Booking Details",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildDetailRow("Provider Company", companyName, theme),
                _buildDetailRow("Status", request.status.toUpperCase(), theme, _getStatusColor(request.status)),
                _buildDetailRow("Booking Date", request.dateTime.toLocal().toString().split(' ')[0], theme),
                if (request.status == 'accepted' || request.status == 'completed') ...[
                  _buildDetailRow(
                    "Provider Phone",
                    phone.isNotEmpty ? phone : "Not Provided",
                    theme,
                    null,
                    phone.isNotEmpty ? () => launchUrl(Uri.parse('tel:$phone')) : null,
                  ),
                  _buildDetailRow(
                    "Provider Email",
                    email.isNotEmpty ? email : "Not Provided",
                    theme,
                    null,
                    email.isNotEmpty ? () => launchUrl(Uri.parse('mailto:$email')) : null,
                  ),
                ],
                if (request.message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    "Your Message",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      request.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(
                      "Close",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, [Color? valueColor, VoidCallback? onTap]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (onTap != null ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orangeAccent;
    if (status == 'accepted') return Colors.blueAccent;
    if (status == 'completed') return Colors.greenAccent;
    return Colors.redAccent;
  }
}
