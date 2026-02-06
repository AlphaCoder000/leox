import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:leox/views/employer/employer_login_view.dart';
import 'package:leox/views/privacy_policy_view.dart';
import 'package:leox/views/terms_of_service_view.dart';
import 'package:sizer/sizer.dart';

class RoleOptionView extends StatelessWidget {
  const RoleOptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 250, 1),

      // ✅ APP BAR WITH BACK BUTTON
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            Text(
              "Welcome to Leox",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(0, 0, 0, 0.87),
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              "Choose how you'd like to continue",
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color.fromRGBO(0, 0, 0, 0.6),
              ),
            ),

            SizedBox(height: 4.h),

            // 🔹 EMPLOYER CARD (TOP)
            _roleCard(
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
                // TODO → Employee Login / Register
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

  Widget _roleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> points,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color.fromRGBO(66, 133, 244, 0.15),
                  child: Icon(
                    icon,
                    size: 30,
                    color: const Color.fromRGBO(66, 133, 244, 1),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
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
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              ...points.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Color.fromRGBO(66, 133, 244, 1),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(p, style: TextStyle(fontSize: 12.5.sp)),
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
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color.fromRGBO(0, 0, 0, 0.6),
        ),
        children: [
          const TextSpan(text: "By continuing, you agree to our "),

          TextSpan(
            text: "Terms of Service",
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Color.fromRGBO(66, 133, 244, 1),
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
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Color.fromRGBO(66, 133, 244, 1),
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
