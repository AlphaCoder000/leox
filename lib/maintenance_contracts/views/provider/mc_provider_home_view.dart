import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../controllers/mc_provider_auth_controller.dart';

class McProviderHomeView extends StatelessWidget {
  const McProviderHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McProviderDashboardController>();
    final authController = context.watch<McProviderAuthController>();
    final provider = authController.currentProvider;

    if (dashboardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeOps = dashboardController.services.length;
    final pendingReqs = dashboardController.requests.where((r) => r.status == 'pending').length;
    final completed = dashboardController.requests.where((r) => r.status == 'completed').length;
    
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, ${provider?.companyName ?? 'Provider'}!",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildStatCard("Active Services", activeOps.toString(), Colors.blueAccent),
              SizedBox(width: 4.w),
              _buildStatCard("Pending Requests", pendingReqs.toString(), Colors.orangeAccent),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildStatCard("Completed Jobs", completed.toString(), Colors.greenAccent),
              SizedBox(width: 4.w),
              _buildStatCard("Overall Rating", "${provider?.rating ?? 0.0} ★", Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, color: color, size: 24.sp),
              SizedBox(height: 1.h),
              Text(
                value,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 0.5.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
