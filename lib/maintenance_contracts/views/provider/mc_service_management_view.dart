import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../models/mc_service_model.dart';
import 'package:leox/widgets/custom_popup.dart';

class McServiceManagementView extends StatelessWidget {
  const McServiceManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McProviderDashboardController>();
    final providerId = context.read<McProviderAuthController>().currentProvider?.id ?? '';

    return Scaffold(
      body: dashboardController.services.isEmpty
          ? _buildEmptyState(context)
          : _buildServicesList(context, dashboardController.services, providerId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context, providerId),
        backgroundColor: const Color(0xFF0EA5E9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add Service",
          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ),
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
              Icons.build_outlined,
              size: 50.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "No Services Listed",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Add your first maintenance service to get started.",
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, List services, String providerId) {
    final dashboardController = context.read<McProviderDashboardController>();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(4.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = services[index];
                return _buildServiceCard(context, service, providerId, dashboardController);
              },
              childCount: services.length,
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 10.h)),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, service, String providerId, McProviderDashboardController dashboardController) {
    final theme = Theme.of(context);
    return Container(
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
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.build_outlined,
                    color: const Color(0xFF0EA5E9),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        service.category,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${service.price}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            if (service.description.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, service, providerId, dashboardController);
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 22.sp),
                    label: Text(
                      "Delete",
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
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, service, String providerId, McProviderDashboardController dashboardController) {
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
              Navigator.pop(ctx);
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

  void _showAddServiceDialog(BuildContext context, String providerId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: "Service Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: catCtrl,
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Price",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text("Cancel"),
                      ),
                      SizedBox(width: 2.w),
                       ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (titleCtrl.text.trim().isNotEmpty && 
                              catCtrl.text.trim().isNotEmpty && 
                              priceCtrl.text.trim().isNotEmpty) {
                            final newService = McServiceModel(
                              id: '',
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              category: catCtrl.text.trim(),
                              price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                              providerId: providerId,
                            );
                            context.read<McProviderDashboardController>().addService(newService);
                            Navigator.pop(ctx);
                            
                            await CustomPopup.show(
                              context,
                              type: CustomPopupType.success,
                              title: 'Service Added!',
                              message: 'Your service "${newService.title}" has been listed successfully.',
                              buttonLabel: 'Awesome',
                            );
                          }
                        },
                        child: Text("Add Service"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
