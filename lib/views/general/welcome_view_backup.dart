import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/welcome_provider.dart';
import '../../models/resource_model.dart';

/// Backup code for LeoOpus Welcome View features.
/// This includes the Key Features section, Resources section, Footer, and the dialog.
/// You can paste these methods back into `welcome_view.dart` when needed.

/*
// Add these lines to the Column children inside _buildWelcomeContent in `welcome_view.dart`:
_featuresSection(context),
_resourcesSection(context),
_footer(context),
*/

// ==========================================
// 🔹 KEY FEATURES SECTION
// ==========================================
Widget buildFeaturesSection(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SMALL PILL
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Key Features",
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // MAIN HEADING
        Text(
          "Everything you need to streamline hiring.",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),

        SizedBox(height: 1.5.h),

        // SUB HEADING
        Text(
          "From AI-powered resume screening to a centralized candidate database, "
          "LeoOpus provides the tools to build your dream team.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16.sp,
            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            height: 1.5,
          ),
        ),

        SizedBox(height: 4.h),

        // FEATURE CARDS
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: WelcomeController.features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final feature = WelcomeController.features[index];
            return Card(
              color: theme.cardTheme.color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature.icon,
                          color: colorScheme.primary,
                          size: 20.sp,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        feature.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        feature.description,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                              isDark
                                  ? Colors.grey[500]
                                  : const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

// ==========================================
// 🔹 INSIGHTS & RESOURCES SECTION
// ==========================================
Widget buildResourcesSection(BuildContext context, Function(BuildContext, ResourceModel) openResourceDialog) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TOP LABEL
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Resources",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // 🔹 MAIN HEADING
        Center(
          child: Text(
            "Insights & Resources",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        SizedBox(height: 1.5.h),

        // 🔹 SUB HEADING
        Center(
          child: Text(
            "Explore our collection of articles on hiring, career growth, and industry trends.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // 🔹 FULL WIDTH CARDS
        ...WelcomeController.resources.map((res) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 3.h),
            child: Card(
              elevation: 0,
              color: theme.cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => openResourceDialog(context, res),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 3.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        res.category,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        res.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      SizedBox(height: 1.5.h),

                      Text(
                        res.shortDescription,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              isDark
                                  ? Colors.grey[500]
                                  : const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 2.5.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Read More",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 14.sp,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        SizedBox(height: 4.h),
      ],
    ),
  );
}

// ==========================================
// 🔹 FOOTER SECTION
// ==========================================
Widget buildFooter(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Column(
      children: [
        const Divider(),
        SizedBox(height: 2.h),

        // Original Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "© 2026 ",
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFF8B5CF6),
                    ],
                  ).createShader(bounds),
              child: Text(
                "LeoOpus",
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ==========================================
// 🔥 RESOURCE POPUP DIALOG
// ==========================================
void openResourceDialog(BuildContext context, ResourceModel res) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 90.w,
          height: 70.h,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        res.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  res.category,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                const Divider(),

                // Scrollable content
                Expanded(
                  child: ListView.builder(
                    itemCount: res.points.length,
                    itemBuilder: (context, index) {
                      final point = res.points[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}. ${point.title}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.8.h),
                            Text(
                              point.description,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
