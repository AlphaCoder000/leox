import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../controllers/mc_provider_auth_controller.dart';

class McRequestManagementView extends StatelessWidget {
  const McRequestManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McProviderDashboardController>();
    final providerId = context.read<McProviderAuthController>().currentProvider?.id ?? '';

    final requests = dashboardController.requests;

    return Scaffold(
      body: requests.isEmpty
          ? Center(child: Text("No incoming requests.", style: TextStyle(color: Colors.grey, fontSize: 14.sp)))
          : ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: request.status == 'pending' ? Colors.orangeAccent.withValues(alpha: 0.5) : Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Request for Service ID: ${request.serviceId}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.white)),
                        SizedBox(height: 1.h),
                        Text("Status: ${request.status.toUpperCase()}", style: TextStyle(color: _getStatusColor(request.status), fontWeight: FontWeight.bold)),
                        SizedBox(height: 1.h),
                        if (request.status == 'pending') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  dashboardController.updateRequestStatus(request.id, 'rejected', providerId);
                                },
                                child: const Text("Reject", style: TextStyle(color: Colors.redAccent)),
                              ),
                              SizedBox(width: 2.w),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                onPressed: () {
                                  dashboardController.updateRequestStatus(request.id, 'accepted', providerId);
                                },
                                child: const Text("Accept", style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ] else if (request.status == 'accepted') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                                onPressed: () {
                                  dashboardController.updateRequestStatus(request.id, 'completed', providerId);
                                },
                                child: const Text("Mark Completed", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
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
