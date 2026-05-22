import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../models/mc_service_model.dart';
import '../../models/mc_request_model.dart';

class McProviderHomeView extends StatelessWidget {
  final Function(int)? onNavigate;
  const McProviderHomeView({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McProviderDashboardController>();
    final authController = context.watch<McProviderAuthController>();
    final provider = authController.currentProvider;
    final theme = Theme.of(context);

    if (dashboardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeOps = dashboardController.services.length;
    final pendingReqs = dashboardController.requests.where((r) => r.status == 'pending').length;
    final completed = dashboardController.requests.where((r) => r.status == 'completed').length;
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text(
                  "Provider Dashboard",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  "Welcome back, ${provider?.companyName ?? 'Provider'}!",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 2.h),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.7,
                  children: [
                    _buildStatCard(context, "Active Services", activeOps.toString(), Colors.blue, Icons.build_outlined),
                    _buildStatCard(context, "Pending Requests", pendingReqs.toString(), Colors.orange, Icons.pending_actions_outlined),
                    _buildStatCard(context, "Completed Jobs", completed.toString(), Colors.green, Icons.task_alt_outlined),
                    _buildStatCard(context, "Overall Rating", "${provider?.rating ?? 0.0}", Colors.amber, Icons.star_outlined),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildQuickActions(context),
                SizedBox(height: 3.h),
                _buildRecentActivity(context, dashboardController),
                SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(0.5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(1.2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(height: 0.2.h),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 0.2.h),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    "Add Service",
                    Icons.add_circle_outline,
                    Colors.blue,
                    () {
                      if (onNavigate != null) {
                        onNavigate!(1); // index 1 is Services
                      } else {
                        Navigator.pushReplacementNamed(context, '/provider-dashboard');
                      }
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _actionButton(
                    context,
                    "View Requests",
                    Icons.list_alt_outlined,
                    Colors.orange,
                    () {
                      if (onNavigate != null) {
                        onNavigate!(2); // index 2 is Requests
                      } else {
                        Navigator.pushReplacementNamed(context, '/provider-dashboard');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: color.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, McProviderDashboardController controller) {
    final theme = Theme.of(context);
    final services = controller.services.take(3).toList();
    final requests = controller.requests.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        if (services.isNotEmpty) ...[
          Text(
            "Recent Services",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 1.h),
          ...services.map((service) => _buildServiceItem(context, service)),
        ],
        if (requests.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            "Recent Requests",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 1.h),
          ...requests.map((request) => _buildRequestItem(context, request)),
        ],
      ],
    );
  }

  Widget _buildServiceItem(BuildContext context, McServiceModel service) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showServiceDetailSheet(context, service),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.build_outlined, color: const Color(0xFF0EA5E9), size: 18.sp),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    service.category,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                service.priceRange.isNotEmpty ? service.priceRange : "₹${service.price}",
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: const Color(0xFF0EA5E9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, McRequestModel request) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showRequestDetailSheet(context, request),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getRequestStatusColor(request.status).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: _getRequestStatusColor(request.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pending_actions_outlined, color: _getRequestStatusColor(request.status), size: 18.sp),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.seekerName.isNotEmpty ? request.seekerName : "Company",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "Service Request",
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _getRequestStatusColor(request.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 17.sp,
                  color: _getRequestStatusColor(request.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showServiceDetailSheet(BuildContext context, McServiceModel service) {
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
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.category,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF0EA5E9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                if (service.description.isNotEmpty) ...[
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Estimated Price Range",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      service.priceRange.isNotEmpty ? service.priceRange : "₹${service.price}",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                  ],
                ),
                if (service.priceJustification.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    "Price Justification",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    service.priceJustification,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      height: 1.5,
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

  void _showRequestDetailSheet(BuildContext context, McRequestModel request) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                Text(
                  "Request Details",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildDetailRow("Company", request.seekerName.isNotEmpty ? request.seekerName : "Unknown", theme),
                
                _buildDetailRow("Status", request.status.toUpperCase(), theme, _getRequestStatusColor(request.status)),
                if (request.seekerName.isNotEmpty) 
                if (request.seekerPhone.isNotEmpty) _buildDetailRow("Phone", request.seekerPhone, theme),
                if (request.seekerAddress.isNotEmpty) _buildDetailRow("Address", request.seekerAddress, theme),
                if (request.message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    "Message",
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
                        fontSize: 17.sp,
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
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
