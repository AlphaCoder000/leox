import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:leox/views/employee/employee_login_view.dart';
import 'package:leox/views/employer/employer_login_view.dart';
import 'package:leox/views/privacy_policy_view.dart';
import 'package:leox/views/terms_of_service_view.dart';
import 'package:leox/views/welcome_view.dart';
import 'package:sizer/sizer.dart';

class RoleOptionView extends StatelessWidget {
  const RoleOptionView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Uses Theme
      // ✅ APP BAR WITH BACK BUTTON
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeView()),
            (route) => false,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            Text(
              "Welcome to LeoRecruit",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              "Choose how you'd like to continue",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color:
                    isDark
                        ? Colors.grey[400]
                        : const Color.fromRGBO(0, 0, 0, 0.6),
              ),
            ),

            SizedBox(height: 4.h),

            // 🔹 EMPLOYER CARD (TOP)
            _roleCard(
              context,
              title: "I'm an Employer",
              subtitle: "Post jobs and find the best candidates",
              icon: Icons.business_center_outlined,
              points: const [
                "Post job openings",
                "Review applications",
                "Manage candidates",
                "Schedule interviews",
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployerLoginView()),
                );
              },
            ),

            SizedBox(height: 3.h),

            // 🔹 EMPLOYEE CARD (BOTTOM)
            _roleCard(
              context,
              title: "I'm an Employee",
              subtitle: "Find and apply for your dream job",
              icon: Icons.person_outline,
              points: const [
                "Browse job openings",
                "Submit applications",
                "Track application status",
                "Get interview notifications",
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeLoginView()),
                );
              },
            ),

            SizedBox(height: 4.h),

            // 🔹 TERMS & PRIVACY
            _termsAndPrivacy(context),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  // =============================================================

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> points,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        color: theme.cardTheme.color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black.withAlpha(5),
                  child: Icon(icon, size: 30, color: theme.primaryColor),
                ),
              ),

              SizedBox(height: 2.h),

              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              Center(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:
                        isDark
                            ? Colors.grey[400]
                            : const Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              ...points.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: theme.primaryColor,
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================

  Widget _termsAndPrivacy(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.grey[500] : const Color.fromRGBO(0, 0, 0, 0.6),
        ),
        children: [
          const TextSpan(text: "By continuing, you agree to our "),

          TextSpan(
            text: "Terms of Service",
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsOfServiceView(),
                      ),
                    );
                  },
          ),

          const TextSpan(text: " and "),

          TextSpan(
            text: "Privacy Policy",
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyView(),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
