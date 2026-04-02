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

    return Card(
      elevation: 3,
      shadowColor: Colors.white.withOpacity(0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 22.h, // Increased height from 18.h to 22.h
        child: Padding(
          padding: EdgeInsets.all(3.w), // Increased padding from 2.5.w to 3.w
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TOP SECTION: Icon + Value
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON - Bigger
                  Icon(icon, size: 22.sp, color: colorScheme.primary), // Increased from 18.sp

                  SizedBox(height: 1.h), // Increased from 0.5.h

                  // VALUE - Much bigger
                  Text(
                    value.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp, // Increased from 16.sp
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                ],
              ),

              // MIDDLE: Title - Bigger
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp, // Updated from 16.sp to 18.sp
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.0,
                ),
              ),

              // BOTTOM: Subtitle - Bigger
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp, // Updated from 12.sp to 15.sp
                  color: colorScheme.onSurface.withOpacity(0.7),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
