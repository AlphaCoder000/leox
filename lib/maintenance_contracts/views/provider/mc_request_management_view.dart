import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../models/mc_request_model.dart';

class McRequestManagementView extends StatelessWidget {
  const McRequestManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McProviderDashboardController>();
    final providerId = context.read<McProviderAuthController>().currentProvider?.id ?? '';

    final requests = dashboardController.requests;

    return Scaffold(
      body: requests.isEmpty
          ? _buildEmptyState(context)
          : _buildRequestsList(requests, dashboardController, providerId, context),
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
              Icons.pending_actions_outlined,
              size: 50.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "No Incoming Requests",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "You don't have any service requests yet.",
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List requests, McProviderDashboardController dashboardController, String providerId, BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(4.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final request = requests[index];
                return _buildRequestCard(request, dashboardController, providerId, theme, context);
              },
              childCount: requests.length,
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 5.h)),
      ],
    );
  }

  Widget _buildRequestCard(McRequestModel request, McProviderDashboardController dashboardController, String providerId, ThemeData theme, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('mc_seekers').doc(request.seekerId).get(),
      builder: (context, snapshot) {
        String seekerName = request.seekerName.isNotEmpty ? request.seekerName : "Loading Seeker...";
        String seekerPhone = request.seekerPhone;
        String seekerEmail = "";
        String seekerAddress = request.seekerAddress;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          seekerName = data?['userName'] ?? request.seekerName;
          seekerPhone = data?['phone'] ?? request.seekerPhone;
          seekerEmail = data?['email'] ?? '';
          seekerAddress = data?['address'] ?? request.seekerAddress;
        }
        if (seekerName.isEmpty) seekerName = "Unknown Customer";

        final isRevealed = request.status == 'accepted' || request.status == 'completed';

        return GestureDetector(
          onTap: () => _showRequestDetailSheet(context, request, seekerName, seekerPhone, seekerEmail, seekerAddress),
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
                              seekerName,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Service Request",
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
                  if (request.message.isNotEmpty) ...[
                    SizedBox(height: 1.5.h),
                    Text(
                      "Message",
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
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contact_phone_outlined, size: 15.sp, color: Colors.green),
                              SizedBox(width: 2.w),
                              Text(
                                "Customer Contact Details",
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                              SizedBox(width: 2.w),
                              Text(
                                seekerName,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.8.h),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 14.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                              SizedBox(width: 2.w),
                              Text(
                                seekerPhone.isNotEmpty ? seekerPhone : "Not Provided",
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          if (seekerEmail.isNotEmpty) ...[
                            SizedBox(height: 0.8.h),
                            Row(
                              children: [
                                Icon(Icons.email_outlined, size: 14.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                SizedBox(width: 2.w),
                                Text(
                                  seekerEmail,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (seekerAddress.isNotEmpty) ...[
                            SizedBox(height: 0.8.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 0.2.h),
                                  child: Icon(Icons.location_on_outlined, size: 14.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    seekerAddress,
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 2.h),
                  if (request.status == 'pending') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            dashboardController.updateRequestStatus(request.id, 'rejected', providerId);
                          },
                          icon: Icon(Icons.close, size: 18.sp),
                          label: Text(
                            "Reject",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        ElevatedButton.icon(
                          onPressed: () {
                            dashboardController.updateRequestStatus(request.id, 'accepted', providerId);
                          },
                          icon: Icon(Icons.check, size: 18.sp),
                          label: Text(
                            "Accept",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (request.status == 'accepted') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            dashboardController.updateRequestStatus(request.id, 'completed', providerId);
                          },
                          icon: Icon(Icons.task_alt, size: 18.sp),
                          label: Text(
                            "Mark Complete",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
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

  void _showRequestDetailSheet(BuildContext context, McRequestModel request, String name, String phone, String email, String address) {
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
                        "Request Details",
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
                _buildDetailRow("Company Name", name, theme),
                _buildDetailRow("Status", request.status.toUpperCase(), theme, _getStatusColor(request.status)),
                if (request.status == 'accepted' || request.status == 'completed') ...[
                  _buildDetailRow("Phone", phone.isNotEmpty ? phone : "Not Provided", theme),
                  if (email.isNotEmpty) _buildDetailRow("Email", email, theme),
                  _buildDetailRow("Address", address.isNotEmpty ? address : "Not Provided", theme),
                ],
                if (request.message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    "Message from Seeker",
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

  Widget _buildDetailRow(String label, String value, ThemeData theme, [Color? valueColor]) {
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
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
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
