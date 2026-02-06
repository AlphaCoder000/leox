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

  static const Color cardBg = Color.fromRGBO(255, 255, 255, 1);
  static const Color borderColor = Color.fromRGBO(220, 225, 230, 1);
  static const Color titleColor = Color.fromRGBO(0, 0, 0, 0.87);
  static const Color subtitleColor = Color.fromRGBO(0, 0, 0, 0.55);
  static const Color iconBg = Color.fromRGBO(66, 133, 244, 0.12);
  static const Color iconColor = Color.fromRGBO(66, 133, 244, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 20),
          ),

          SizedBox(height: 1.5.h),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 0.8.h),

          // Value
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),

          SizedBox(height: 0.8.h),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.5.sp, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
