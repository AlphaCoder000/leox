import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import 'mc_service_details_view.dart';

class McSeekerCatalogView extends StatelessWidget {
  const McSeekerCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McSeekerDashboardController>();

    if (dashboardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final services = dashboardController.allServices;

    return services.isEmpty
        ? Center(child: Text("No services available.", style: TextStyle(color: Colors.grey, fontSize: 14.sp)))
        : ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => McServiceDetailsView(service: service)),
                  );
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.sp,
                          backgroundColor: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                          child: Icon(Icons.build, color: const Color(0xFF0EA5E9), size: 20.sp),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.white)),
                              SizedBox(height: 0.5.h),
                              Text(service.category, style: TextStyle(color: Colors.grey[400], fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        Text("\$${service.price}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: const Color(0xFF0EA5E9))),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
