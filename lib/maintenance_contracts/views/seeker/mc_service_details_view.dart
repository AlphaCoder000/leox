import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import '../../controllers/mc_seeker_auth_controller.dart';
import '../../models/mc_service_model.dart';
import '../../models/mc_request_model.dart';
import 'package:leox/widgets/custom_popup.dart';

class McServiceDetailsView extends StatelessWidget {
  final McServiceModel service;

  const McServiceDetailsView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final titleColor = isDark ? Colors.white : const Color.fromARGB(255, 27, 26, 26);
    final categoryColor = const Color(0xFF0EA5E9);
    final headingColor = isDark ? const Color.fromARGB(255, 255, 138, 138) : const Color.fromARGB(255, 83, 26, 26);
    final descTextColor = isDark ? Colors.grey[300] : const Color.fromARGB(255, 40, 39, 39);
    final priceHeadingColor = isDark ? const Color.fromARGB(255, 255, 138, 138) : const Color.fromARGB(255, 80, 34, 34);
    final priceTextColor = isDark ? const Color.fromARGB(255, 208, 169, 237) : const Color.fromARGB(255, 59, 41, 75);

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
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: titleColor)),
                  SizedBox(height: 1.h),
                  Text(service.category, style: TextStyle(fontSize: 18.sp, color: categoryColor)),
                  SizedBox(height: 2.h),
                  Text("Description", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: headingColor)),
                  SizedBox(height: 1.h),
                  Text(service.description, style: TextStyle(fontSize: 17.sp, color: descTextColor)),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Price", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: priceHeadingColor)),
                      Text("₹${service.price}", style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: priceTextColor)),
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
                onPressed: () async {
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
                    
                    await CustomPopup.show(
                      context,
                      type: CustomPopupType.success,
                      title: 'Booking Request Sent!',
                      message: 'Your request for "${service.title}" has been placed successfully and is pending provider approval.',
                      buttonLabel: 'View Bookings',
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text("Book Service", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
