import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import '../../controllers/mc_seeker_auth_controller.dart';
import '../../models/mc_service_model.dart';
import '../../models/mc_request_model.dart';

class McServiceDetailsView extends StatelessWidget {
  final McServiceModel service;

  const McServiceDetailsView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service Details")),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 1.h),
                  Text(service.category, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0EA5E9))),
                  SizedBox(height: 2.h),
                  Text("Description", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey[300])),
                  SizedBox(height: 1.h),
                  Text(service.description, style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Price", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey[300])),
                      Text("\$${service.price}", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final seekerId = context.read<McSeekerAuthController>().currentSeeker?.id;
                  if (seekerId != null) {
                    final newRequest = McRequestModel(
                      id: '',
                      seekerId: seekerId,
                      providerId: service.providerId,
                      serviceId: service.id,
                      status: 'pending',
                      dateTime: DateTime.now(),
                    );
                    context.read<McSeekerDashboardController>().createRequest(newRequest);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service booked successfully!")));
                  }
                },
                child: Text("Book Service", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
