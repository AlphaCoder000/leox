import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 250, 1),

      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading("Privacy Policy"),

            SizedBox(height: 1.h),

            _subText("Last Updated: 12/21/2025"),

            SizedBox(height: 3.h),

            _sectionTitle("1. Introduction"),
            _bodyText(
              "LeoRecruit (\"we\", \"our\", or \"us\") is committed to protecting "
              "your privacy. This policy explains how we collect, use, and "
              "safeguard your information.",
            ),

            SizedBox(height: 2.5.h),

            _sectionTitle("2. Information We Collect"),
            _bodyText(
              "We may collect personal data such as name, email address, "
              "resume information, and job application details.",
            ),

            SizedBox(height: 2.5.h),

            _sectionTitle("3. How We Use Information"),
            _bodyText(
              "Information is used to provide hiring services, improve platform "
              "functionality, and ensure secure authentication.",
            ),

            SizedBox(height: 2.5.h),

            _sectionTitle("4. Data Security"),
            _bodyText(
              "We implement appropriate technical and organizational measures "
              "to protect your personal information.",
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
