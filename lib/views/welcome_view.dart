import 'package:flutter/material.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../providers/welcome_provider.dart';
import '../models/resource_model.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    // Note: Auth state and role-based redirection are now handled centrally in main.dart
    // This view only focuses on displaying the welcome content.
    return _buildWelcomeContent(context);
  }

  Widget _buildWelcomeContent(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(context),
            _heroSection(context),
            _featuresSection(context),
            _resourcesSection(context),
            _footer(context),
          ],
        ),
      ),
    );
  }

  // 🔹 HEADER
  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Spacer to help center the text
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  const Color(0xFF8B5CF6), // Purple pop
                ],
              ).createShader(bounds),
              child: Text(
                "LeoRecruit",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : themeProvider.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.settings_brightness,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
    );
  }

  // 🔹 HERO
  Widget _heroSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Find Your Next Opportunity",
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.5.h),
          Text(
            "Browse jobs and discover roles that match your skills and ambitions.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.grey[400]
                      : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleOptionView()),
                );
              },
              child: Text(
                "Get Started Free",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 FEATURES
  Widget _featuresSection(BuildContext context) {
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
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Key Features",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 15.sp,
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
            "LeoRecruit provides the tools to build your dream team.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
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
                            color: Colors.black.withOpacity(0.05),
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

  // RESOURCES
  Widget _resourcesSection(BuildContext context) {
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
                color: Colors.black.withOpacity(0.05),
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
                  onTap: () => _openResourceDialog(context, res),
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

  // 🔹 FOOTER
  Widget _footer(BuildContext context) {
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
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    const Color(0xFF8B5CF6),
                  ],
                ).createShader(bounds),
                child: Text(
                  "LeoRecruit",
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

  // 🔥 RESOURCE POPUP
  void _openResourceDialog(BuildContext context, ResourceModel res) {
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
}
