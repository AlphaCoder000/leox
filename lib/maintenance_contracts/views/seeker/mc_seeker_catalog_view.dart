import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import 'mc_service_details_view.dart';

class McSeekerCatalogView extends StatelessWidget {
  const McSeekerCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McSeekerDashboardController>();
    final theme = Theme.of(context);

    if (dashboardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final services = dashboardController.allServices;

    return Scaffold(
      body: services.isEmpty
          ? _buildEmptyState(context)
          : _buildServicesList(services, theme),
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
              Icons.handyman_outlined,
              size: 50.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "No Services Available",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Check back later for available maintenance services.",
            style: TextStyle(
              fontSize: 17.sp,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List services, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(4.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = services[index];
                return _buildServiceCard(context, service, theme);
              },
              childCount: services.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, service, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => McServiceDetailsView(service: service)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.cardColor,
          border: Border.all(
            color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.15 : 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.04 : 0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 20.sp,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                            color: theme.colorScheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('mc_providers').doc(service.providerId).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                              final companyName = data?['companyName'] ?? 'Unknown Provider';
                              return Row(
                                children: [
                                  Icon(
                                    Icons.business_rounded,
                                    size: 13.sp,
                                    color: const Color(0xFF0EA5E9),
                                  ),
                                  SizedBox(width: 1.5.w),
                                  Expanded(
                                    child: Text(
                                      companyName,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0EA5E9),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Divider(
                color: theme.dividerColor.withValues(alpha: 0.5),
                height: 1,
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label_outline_rounded,
                          size: 13.sp,
                          color: const Color(0xFF0EA5E9),
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF0EA5E9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    service.priceRange.isNotEmpty ? service.priceRange : "₹${service.price}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17.sp,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
