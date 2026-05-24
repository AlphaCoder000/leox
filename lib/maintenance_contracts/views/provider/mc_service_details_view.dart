import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../models/mc_service_model.dart';
import 'mc_add_service_view.dart';

class McServiceDetailsView extends StatelessWidget {
  final String serviceId;
  final String providerId;

  const McServiceDetailsView({
    super.key,
    required this.serviceId,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardController = context.watch<McProviderDashboardController>();
    
    // Find the service in the controller's list to react to live edits
    final serviceIndex = dashboardController.services.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) {
      // If deleted or not found, pop the details view
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final service = dashboardController.services[serviceIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Service Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withValues(alpha: 0.95)]
                : [theme.scaffoldBackgroundColor, theme.colorScheme.primary.withValues(alpha: 0.02)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Title, Category and Price
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.build_outlined,
                            color: const Color(0xFF0EA5E9),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20.sp,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 0.8.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  service.category,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF0EA5E9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Estimated Price Range",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              service.priceRange.isNotEmpty ? service.priceRange : "₹${service.price}",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22.sp,
                                color: const Color(0xFF0EA5E9),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            service.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Description section
              if (service.description.isNotEmpty) ...[
                _buildDetailsCard(
                  context,
                  title: "Service Scope & Description",
                  icon: Icons.description_rounded,
                  content: service.description,
                ),
                SizedBox(height: 3.h),
              ],

              // Price Justification section
              if (service.priceJustification.isNotEmpty) ...[
                _buildDetailsCard(
                  context,
                  title: "Pricing Range Justification",
                  icon: Icons.rate_review_rounded,
                  content: service.priceJustification,
                ),
                SizedBox(height: 4.h),
              ],

              // Actions (Edit & Delete)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, service, providerId, dashboardController);
                      },
                      icon: Icon(Icons.delete_outline, size: 18.sp),
                      label: Text(
                        "Delete Service",
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => McAddServiceView(
                              providerId: providerId,
                              service: service,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded, color: Colors.white),
                        label: Text(
                          "Edit Service",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, {required String title, required IconData icon, required String content}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF0EA5E9), size: 18.sp),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 15.sp,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, McServiceModel service, String providerId, McProviderDashboardController dashboardController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.sp),
            SizedBox(width: 2.w),
            Text(
              "Confirm Deletion",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete this service?",
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 1.h),
            Text(
              "Service: ${service.title}",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 18.sp),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      "This action cannot be undone.",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton(
            onPressed: () {
              dashboardController.deleteService(service.id, providerId);
              Navigator.pop(ctx); // Close dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Delete",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
