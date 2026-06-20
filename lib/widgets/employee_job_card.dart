import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/job_model.dart';

class EmployeeJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onView;
  final int? index;

  const EmployeeJobCard({
    super.key,
    required this.job,
    required this.onView,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Harmonious modern premium color palette
    final baseColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF14B8A6), // Teal
    ];

    final baseColor = index != null 
        ? baseColors[index! % baseColors.length] 
        : colorScheme.primary;

    final cardBgColor = isDark 
        ? baseColor.withValues(alpha: 0.08) 
        : baseColor.withValues(alpha: 0.04);
    
    final chipBgColor = baseColor.withValues(alpha: 0.12);
    final chipTextColor = isDark 
        ? Color.lerp(baseColor, Colors.white, 0.4) 
        : Color.lerp(baseColor, Colors.black, 0.25);

    return Card(
      color: cardBgColor,
      elevation: 2,
      shadowColor: baseColor.withValues(alpha: isDark ? 0.2 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: baseColor.withValues(alpha: isDark ? 0.25 : 0.12),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TITLE & SUBTITLE =================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sleek vertical color indicator bar
                  Container(
                    width: 4.5,
                    height: 32,
                    margin: EdgeInsets.only(top: 0.5.h),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (job.companyName.isNotEmpty) ...[
                          SizedBox(height: 0.4.h),
                          Text(
                            job.companyName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),

              // ================= META CHIPS =================
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                   if (job.companyName.isNotEmpty)
                     _chip(context, Icons.business_rounded, job.companyName, chipBgColor, chipTextColor),
                   if (job.location.isNotEmpty)
                     _chip(context, Icons.location_on_rounded, job.location, chipBgColor, chipTextColor),
                   if (job.salaryRange.isNotEmpty)
                     _chip(context, Icons.payments_rounded, job.salaryRange, chipBgColor, chipTextColor),
                   if (job.department.isNotEmpty)
                     _chip(context, Icons.apartment_rounded, job.department, chipBgColor, chipTextColor),
                   if (job.category.isNotEmpty)
                     _chip(context, Icons.category_rounded, job.category, chipBgColor, chipTextColor),
                   if (job.jobType.isNotEmpty)
                     _chip(context, Icons.work_outline_rounded, job.jobType, chipBgColor, chipTextColor),
                   if (job.experienceLevel.isNotEmpty)
                     _chip(context, Icons.psychology_rounded, job.experienceLevel, chipBgColor, chipTextColor),
                   _chip(context, Icons.verified_outlined, job.status, chipBgColor, chipTextColor),
                ],
              ),

              SizedBox(height: 1.5.h),

              // ================= DESCRIPTION PREVIEW =================
              Text(
                job.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.45,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                ),
              ),

              SizedBox(height: 1.5.h),
              Divider(
                color: baseColor.withValues(alpha: isDark ? 0.15 : 0.08),
                height: 1,
              ),
              SizedBox(height: 1.5.h),

              // ================= FOOTER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14.sp,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        "Posted on ${job.postedOn.day}/${job.postedOn.month}/${job.postedOn.year}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: chipTextColor ?? colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPER CHIP WIDGET =================

  Widget _chip(BuildContext context, IconData icon, String text, Color? customBg, Color? customText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: customBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (customText ?? Colors.transparent).withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: customText),
          SizedBox(width: 1.2.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: customText,
            ),
          ),
        ],
      ),
    );
  }
}
