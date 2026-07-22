import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leox/widgets/custom_popup.dart';
import 'package:sizer/sizer.dart';

class EmailVerificationView extends StatefulWidget {
  final User user;

  const EmailVerificationView({super.key, required this.user});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  bool _isChecking = false;
  bool _isResending = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 5 seconds as a helper
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus(silent: true));
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_isChecking) return;

    if (!silent) {
      setState(() => _isChecking = true);
    }

    try {
      await widget.user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      
      if (updatedUser != null && updatedUser.emailVerified) {
        _autoRefreshTimer?.cancel();
        if (mounted) {
          // Show a quick success popup and rely on auth state changes to rebuild main.dart
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email verified successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (!silent && mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.warning,
          title: 'Not Verified Yet',
          message: 'We checked, but your email has not been verified yet. Please click the link in the email sent to you.',
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.error,
          title: 'Status Check Failed',
          message: 'Error refreshing status: ${e.toString()}',
        );
      }
    } finally {
      if (mounted && !silent) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      await widget.user.sendEmailVerification();
      if (mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.success,
          title: 'Verification Link Sent',
          message: 'A new verification link has been sent to ${widget.user.email}. Please check your inbox and spam folder.',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.error,
          title: 'Failed to Send Email',
          message: e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _signOut() async {
    _autoRefreshTimer?.cancel();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF030712) : theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : theme.dividerColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("Email Verification", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 ICON HEADER
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 32.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 4.h),

              // 🔹 TITLE
              Text(
                "Verify Your Email",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.5.h),

              // 🔹 DESCRIPTION CARD
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      "We sent a verification link to:",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.user.email ?? "your email",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.5.h),
                    Text(
                      "Please click the verification link in that email to activate your account. If you don't see it, make sure to check your spam folder.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // 🔹 VERIFY STATUS BUTTON
              ElevatedButton.icon(
                onPressed: _isChecking ? null : () => _checkStatus(silent: false),
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  _isChecking ? "Checking..." : "I've Verified My Email",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              SizedBox(height: 2.h),

              // 🔹 RESEND BUTTON
              OutlinedButton.icon(
                onPressed: _isResending ? null : _resendEmail,
                icon: _isResending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                      )
                    : Icon(Icons.send, color: colorScheme.primary),
                label: Text(
                  _isResending ? "Resending..." : "Resend Verification Email",
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 3.h),

              // 🔹 BACK TO LOGIN BUTTON
              TextButton(
                onPressed: _signOut,
                child: Text(
                  "Back to Login Screen",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
