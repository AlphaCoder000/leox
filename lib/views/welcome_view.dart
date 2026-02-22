import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:leox/views/employee/employee_dashboard_view.dart';
import 'package:leox/views/employer/employer_dashboard_view.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../providers/welcome_provider.dart';
import '../models/resource_model.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // If user is logged in, check role and navigate to appropriate dashboard
        if (user != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (!roleSnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final data = roleSnapshot.data!.data() as Map<String, dynamic>?;
              final role = data?['role'];

              if (role == 'employer') {
                return const EmployerDashboardView();
              }

              if (role == 'employee') {
                return const EmployeeDashboardView();
              }

              // If role is not found, show welcome screen
              return _buildWelcomeContent(context);
            },
          );
        }

        // If user is not logged in, show welcome screen
        return _buildWelcomeContent(context);
      },
    );
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        6.w, // left
        5.h, // Top
        6.w, // right
        2.5.h, // bottom
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "LeoRecruit",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find Your Next Opportunity",
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
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleOptionView()),
                  );
                },

                child: Text(
                  "Get Started Free",
                  style: TextStyle(fontSize: 13.sp, color: Colors.white),
                ),
              ),
              SizedBox(width: 4.w),
            ],
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
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Key Features",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 10.sp,
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

  // RESOURCES
  Widget _resourcesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 10.sp,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          const Divider(),
          SizedBox(height: 1.h),
          
          // Theme Mode Selector
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Theme',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final themeProvider = context.read<ThemeProvider>();
                          themeProvider.setLight();
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.light_mode,
                                size: 16.sp,
                                color: isDark ? colorScheme.primary : Colors.white,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Light',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? colorScheme.primary : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final themeProvider = context.read<ThemeProvider>();
                          themeProvider.setDark();
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: !isDark ? theme.cardColor : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.dark_mode,
                                size: 16.sp,
                                color: !isDark ? colorScheme.primary : Colors.white,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Dark',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: !isDark ? colorScheme.primary : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final themeProvider = context.read<ThemeProvider>();
                          themeProvider.setSystem();
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: theme.brightness == ThemeMode.system 
                                ? theme.cardColor 
                                : colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings_system_daydream,
                                size: 16.sp,
                                color: theme.brightness == ThemeMode.system 
                                    ? colorScheme.primary 
                                    : Colors.white,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'System',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.brightness == ThemeMode.system 
                                      ? colorScheme.primary 
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          
          const Divider(),
          SizedBox(height: 2.h),
          
          // Original Footer
          Text(
            "© 2024 LeoRecruit",
            style: TextStyle(
              fontSize: 9.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
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
