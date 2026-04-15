import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 250, 1),

      appBar: AppBar(
        title: const Text("Terms of Service"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading("Terms of Service"),

            SizedBox(height: 1.h),

            _subText("Last Updated: 12/21/2025"),

            SizedBox(height: 3.h),

            _sectionTitle("1. Acceptance of Terms"),
            _bodyText(
              "By accessing or using the LeoOpus platform (\"Service\"), "
              "you agree to be bound by these Terms of Service (\"Terms\"). "
              "If you do not agree, please do not use this Service.",
            ),

            SizedBox(height: 2.5.h),

            _sectionTitle("2. Description of Service"),
            _bodyText(
              "LeoOpus is an internal hiring platform designed to streamline "
              "recruitment processes including job posting, candidate management, "
              "and AI-based resume matching.",
            ),

            SizedBox(height: 2.5.h),

            _sectionTitle("3. User Accounts and Responsibilities"),
            _bodyText(
              "You are responsible for maintaining the confidentiality of your "
              "account credentials and for all activities under your account.",
            ),

            SizedBox(height: 2.5.h),

            _sectionTitle("4. Termination"),
            _bodyText(
              "We reserve the right to suspend or terminate accounts that violate "
              "these Terms or misuse the platform.",
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  // ================== UI HELPERS ==================

  Widget _heading(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromRGBO(0, 0, 0, 0.87),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        height: 1.6,
        color: const Color.fromRGBO(0, 0, 0, 0.7),
      ),
    );
  }

  Widget _subText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color.fromRGBO(0, 0, 0, 0.5),
      ),
    );
  }
}
