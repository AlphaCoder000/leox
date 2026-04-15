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
      shadowColor: Colors.white.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 22.h, // Increased height from 18.h to 22.h
        child: Padding(
          padding: EdgeInsets.all(3.w), // Increased padding from 2.5.w to 3.w
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TOP SECTION: Icon + Value
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON - Bigger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 22.sp, color: colorScheme.primary,), // Increased from 18.sp to 22.sp
                       
                      SizedBox(height: 5.h), // Increased from 0.5.h

                      // VALUE - Much bigger
                      Text(
                        value.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp, // Increased from 16.sp
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ), // Increased from 18.sp

                 
                ],
              ),

              // MIDDLE: Title - Bigger
              Center( 
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19.sp, // Updated from 16.sp to 18.sp
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: 1.0,
                  ),
                ),
              ),

              // BOTTOM: Subtitle - Bigger
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              
                style: TextStyle(
                  fontSize: 16.sp, // Updated from 12.sp to 15.sp
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
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
