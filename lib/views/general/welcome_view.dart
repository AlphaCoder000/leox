import 'package:flutter/material.dart';
import 'package:leox/views/general/role_option_view.dart';
import 'package:leox/views/general/mc_role_option_view.dart';
import 'package:leox/providers/theme_povider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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
            _portalsSection(context),
            SizedBox(height: 5.h), // Clean bottom spacing
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
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.syncopate(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'LEO',
                        style: TextStyle(color: Color.fromARGB(255, 4, 44, 130)),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: 'OPUS',
                        style: TextStyle(color: Color.fromARGB(255, 16, 69, 182)),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
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

  // 🔹 PORTALS (HIRING & MAINTENANCE)
  Widget _portalsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          _buildPortalCard(
            context,
            title: "Hiring Platform", 
            heading: "Find Your Next Opportunity",
            description:
                "Browse and post jobs and discover roles that match your skills and ambitions.",
            buttonText: "Get Started",
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoleOptionView()),
              );
            },
            icon: Icons.work_outline_rounded,
          ),
          SizedBox(height: 4.h),
          _buildPortalCard(
            context,
            title: "Maintenance Contracts",
            heading: "Expert Mechanical Services",
            description:
                "Connect with certified providers for equipment maintenance and repairs.",
            buttonText: "Explore Contracts",
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const McRoleOptionView()),
              );
            },
            icon: Icons.settings_suggest_outlined,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPortalCard(
    BuildContext context, {
    required String title,
    required String heading,
    required String description,
    required String buttonText,
    required VoidCallback onAction,
    required IconData icon,
    bool isPrimary = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor =
        isPrimary
            ? colorScheme.primary
            : const Color(0xFF0EA5E9); // Use a distinct color for MC

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Icon overlay centered perfectly
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 150,
                color: primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PORTAL LABEL
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15.sp,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 3.5.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 1.8.h,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: onAction,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
