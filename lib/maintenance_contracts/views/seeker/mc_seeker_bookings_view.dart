import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';

class McSeekerBookingsView extends StatelessWidget {
  const McSeekerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McSeekerDashboardController>();

    if (dashboardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = dashboardController.myRequests;

    return requests.isEmpty
        ? Center(child: Text("No bookings yet.", style: TextStyle(color: Colors.grey, fontSize: 14.sp)))
        : ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: EdgeInsets.only(bottom: 2.h),
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(4.w),
                  title: Text("Service ID: ${request.serviceId}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text("Booked on: ${request.dateTime.toLocal().toString().split(' ')[0]}", style: TextStyle(color: Colors.grey[400])),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(request.status)),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(color: _getStatusColor(request.status), fontWeight: FontWeight.bold, fontSize: 10.sp),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orangeAccent;
    if (status == 'accepted') return Colors.blueAccent;
    if (status == 'completed') return Colors.greenAccent;
    return Colors.redAccent;
  }
}
