import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:leox/services/session_service.dart';
import 'package:leox/utils/app_theme.dart';
import 'package:leox/widgets/custom_popup.dart';

class EmailVerificationView extends StatefulWidget {
  final User user;

  const EmailVerificationView({super.key, required this.user});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _autoRefreshTimer;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 4 seconds in the background
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _checkStatus(silent: true),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCountdown = 30;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
        });
        timer.cancel();
      }
    });
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Email verified successfully! Welcome to Leo Opus.",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (!silent && mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.warning,
          title: 'Not Verified Yet',
          message:
              'We checked, but your email has not been verified yet. Please open the link sent to your email inbox or spam folder, then tap this button again.',
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.error,
          title: 'Check Failed',
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
    if (_isResending || _resendCountdown > 0) return;

    setState(() => _isResending = true);

    try {
      await widget.user.sendEmailVerification();
      _startResendCooldown();
      if (mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.success,
          title: 'New Link Sent!',
          message:
              'A fresh verification email has been dispatched to ${widget.user.email}. Please check your Inbox and Spam / Junk folders.',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.show(
          context,
          type: CustomPopupType.error,
          title: 'Failed to Send',
          message: e.toString().replaceAll("Exception: ", ""),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _openMailApp() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto');
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not launch mail app automatically. Please open your Gmail/Mail app manually.',
              ),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please open your email application to check for the verification link.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();
    await SessionService.clearAuth();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder =
        isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Email Verification",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
            label: Text(
              "Log Out",
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 1. ANIMATED HERO ICON
                Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 4,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mark_email_unread_rounded,
                          size: 36.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // 🔹 2. TITLE & SUBTITLE (Enhanced font sizes)
                Text(
                  "Check Your Inbox",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "We have sent a secure verification link to activate your Leo Opus account.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 2.5.h),

                // 🔹 3. EMAIL DISPLAY CARD
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.alternate_email_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verification sent to:",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              widget.user.email ?? "your-email@example.com",
                              style: GoogleFonts.inter(
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0284C7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),

                // 🔹 4. STEP-BY-STEP INSTRUCTIONS CARD
                Container(
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cardBorder, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How to verify in 3 simple steps:",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.8.h),
                      _buildStepRow(
                        stepNumber: "1",
                        title: "Open your Email App",
                        subtitle: "Check Gmail, Apple Mail, or Outlook inbox.",
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      SizedBox(height: 1.5.h),
                      _buildStepRow(
                        stepNumber: "2",
                        title: "Tap the Verification Link",
                        subtitle: "Look for an email from Leo Opus / Firebase.",
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      SizedBox(height: 1.5.h),
                      _buildStepRow(
                        stepNumber: "3",
                        title: "Return to App & Continue",
                        subtitle: "The app auto-detects your verification instantly!",
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),

                // 🔹 5. SPAM & PROMOTIONS FOLDER CALLOUT (Clear advisory)
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF451A03).withValues(alpha: 0.3)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                          : const Color(0xFFFCD34D),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Can't find the email?",
                              style: GoogleFonts.inter(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Check your Spam, Junk, or Promotions folder. If found there, tap \"Report not spam\" to ensure you receive future job updates directly in your inbox.",
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark ? const Color(0xFFFDE68A).withValues(alpha: 0.9) : const Color(0xFF78350F),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.5.h),

                // 🔹 6. ACTION BUTTON: OPEN MAIL APP (Primary 1-Tap)
                Container(
                  height: 6.8.h,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _openMailApp,
                    icon: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 22),
                    label: Text(
                      "Open Email App",
                      style: GoogleFonts.inter(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.8.h),

                // 🔹 7. ACTION BUTTON: "I'VE VERIFIED MY EMAIL"
                SizedBox(
                  height: 6.5.h,
                  child: OutlinedButton.icon(
                    onPressed: _isChecking ? null : () => _checkStatus(silent: false),
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0284C7),
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                    label: Text(
                      _isChecking ? "Checking Status..." : "I've Verified My Email",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0284C7), width: 1.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                          : const Color(0xFFE0F2FE),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                // 🔹 8. RESEND EMAIL BUTTON WITH COUNTDOWN COOLDOWN
                TextButton.icon(
                  onPressed: (_isResending || _resendCountdown > 0) ? null : _resendEmail,
                  icon: _isResending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: _resendCountdown > 0 ? textSecondary : const Color(0xFF0284C7),
                        ),
                  label: Text(
                    _resendCountdown > 0
                        ? "Resend link available in ${_resendCountdown}s"
                        : (_isResending ? "Sending fresh link..." : "Resend Verification Email"),
                    style: GoogleFonts.inter(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: _resendCountdown > 0 ? textSecondary : const Color(0xFF0284C7),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),

                // 🔹 9. WRONG EMAIL / SWITCH ACCOUNT
                Center(
                  child: TextButton(
                    onPressed: _signOut,
                    child: Text(
                      "Entered wrong email? Switch Account",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0284C7),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
