import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class OtpVerificationSheet extends StatefulWidget {
  final String target; // Phone number or Email
  final Future<bool> Function(String code) onVerify;
  final Future<void> Function() onResend;

  const OtpVerificationSheet({
    super.key,
    required this.target,
    required this.onVerify,
    required this.onResend,
  });

  /// Static helper to display the sheet easily
  static Future<bool?> show(
    BuildContext context, {
    required String target,
    required Future<bool> Function(String code) onVerify,
    required Future<void> Function() onResend,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: OtpVerificationSheet(
          target: target,
          onVerify: onVerify,
          onResend: onResend,
        ),
      ),
    );
  }

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  static const int _timerDuration = 60;
  int _secondsRemaining = _timerDuration;
  Timer? _timer;
  bool _isResending = false;
  bool _isVerifying = false;
  String? _errorMessage;

  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = _timerDuration;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await widget.onResend();
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification code resent successfully."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to resend code: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() {
        _errorMessage = "Please enter the complete 6-digit code.";
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onVerify(code);
      if (success) {
        if (mounted) {
          Navigator.pop(context, true); // Return success
        }
      } else {
        setState(() {
          _errorMessage = "Invalid verification code. Please check and try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : theme.dividerColor;
    final boxFill = isDark ? const Color(0xFF1E293B) : Colors.grey.shade50;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 HANDLE BAR
          Center(
            child: Container(
              width: 12.w,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // 🔹 TITLE
          Text(
            "Verify Phone Number",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),

          // 🔹 SUBTITLE
          Text(
            "Enter the 6-digit code sent to\n${widget.target}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4.h),

          // 🔹 6 DIGIT PIN BOXES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 10.w,
                height: 12.w,
                child: KeyboardListener(
                  focusNode: FocusNode(), // Dummy focus node for key listener
                  onKeyEvent: (event) {
                    // Handle backspace when text field is empty
                    if (event is KeyDownEvent && 
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _controllers[index].text.isEmpty &&
                        index > 0) {
                      _focusNodes[index - 1].requestFocus();
                      _controllers[index - 1].clear();
                    }
                  },
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: boxFill,
                      contentPadding: EdgeInsets.symmetric(vertical: 0.5.h),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderCol, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else {
                          _focusNodes[index].unfocus();
                          _handleVerify(); // Auto-verify on final digit
                        }
                      }
                    },
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 3.h),

          // 🔹 ERROR MESSAGE
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // 🔹 BUTTONS
          ElevatedButton(
            onPressed: _isVerifying ? null : _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isVerifying
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    "Verify Code",
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
          ),
          SizedBox(height: 2.h),

          // 🔹 RESEND SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              GestureDetector(
                onTap: _secondsRemaining == 0 && !_isResending ? _handleResend : null,
                child: Text(
                  _secondsRemaining > 0
                      ? "Resend in ${_secondsRemaining}s"
                      : "Resend Code",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining == 0 && !_isResending
                        ? colorScheme.primary
                        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
