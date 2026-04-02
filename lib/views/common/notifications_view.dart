import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../providers/employer_auth_provider.dart';
import '../../providers/employee_providers/employee_auth_provider.dart';
import '../../widgets/employer_drawer.dart';
import '../../widgets/employee_drawer.dart';
import '../../constants/employer_drawer_item.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final employerAuth = context.watch<EmployerAuthProvider>();
    final employeeAuth = context.watch<EmployeeAuthProvider>();
    
    final bool isEmployer = employerAuth.isLoggedIn;

    return Scaffold(
      drawer: isEmployer 
          ? const EmployerDrawer(selectedItem: EmployerDrawerItem.notifications)
          : const EmployeeDrawer(selectedItem: EmployeeDrawerItem.notifications),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: const Text("Clear All"),
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationProvider>().refresh();
              },
              child: notificationProvider.notifications.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.all(4.w),
                      physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                      itemCount: notificationProvider.notifications.length,
                      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                      itemBuilder: (context, index) {
                        final notification = notificationProvider.notifications[index];
                        return _buildNotificationCard(context, notification);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 40.w,
                  color: Colors.grey.withOpacity(0.3),
                ),
                SizedBox(height: 2.h),
                Text(
                  "No notifications yet",
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "We'll notify you when an update occurs.",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: () {
        if (isUnread) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
        showDialog(
          context: context,
          builder: (alertDialogContext) => AlertDialog(
            title: Text(notification.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            content: Text(notification.message, style: TextStyle(fontSize: 14.sp, color: theme.textTheme.bodyMedium?.color)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(alertDialogContext);
                  context.read<NotificationProvider>().deleteNotification(notification.id);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isUnread 
            ? theme.colorScheme.primary.withOpacity(0.05) 
            : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread 
              ? theme.colorScheme.primary.withOpacity(0.2) 
              : theme.dividerColor.withOpacity(0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                color: _getTypeColor(notification.type),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeago.format(notification.createdAt),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          GestureDetector(
                            onTap: () {
                              context.read<NotificationProvider>().deleteNotification(notification.id);
                            },
                            child: Icon(Icons.delete_outline, size: 19.sp, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(left: 2.w, top: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'application_status': return Icons.info_outline;
      case 'new_job': return Icons.work_outline;
      case 'hired': return Icons.verified_outlined;
      case 'new_application': return Icons.person_add_outlined;
      case 'application_submitted': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      case 'shortlisted': return Icons.star_outline;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hired': return Colors.purple;
      case 'application_status': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'shortlisted': return Colors.orange;
      case 'new_application': return Colors.green;
      case 'application_submitted': return Colors.blue;
      default: return Colors.orange;
    }
  }
}
