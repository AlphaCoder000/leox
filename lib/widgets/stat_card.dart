import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON
                Icon(icon, size: 22.sp, color: colorScheme.primary),

                SizedBox(height: 1.h),

                // VALUE
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 0.6.h),

                // TITLE
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),

                const Spacer(), // ⭐ absorbs remaining space safely
                // SUBTITLE (smallest text at bottom)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.2, // 🔑 REDUCED line height
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
