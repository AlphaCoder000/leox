import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Types of Custom Dialogs
enum CustomPopupType { success, error, warning, info }

/// A premium, beautiful custom popup dialog with smooth scaling animation,
/// vibrant modern colors, tailored dark/light mode compatibility, and micro-animations.
class CustomPopup extends StatefulWidget {
  final CustomPopupType type;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final List<String>? details;

  const CustomPopup({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.buttonLabel = 'Continue',
    this.onButtonPressed,
    this.details,
  });

  /// Static method to show the beautiful popup with a scale transition
  static Future<void> show(
    BuildContext context, {
    required CustomPopupType type,
    required String title,
    required String message,
    String buttonLabel = 'Continue',
    VoidCallback? onButtonPressed,
    List<String>? details,
  }) async {
    if (!context.mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curveValue = Curves.easeInOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curveValue,
          child: Opacity(
            opacity: anim1.value,
            child: CustomPopup(
              type: type,
              title: title,
              message: message,
              buttonLabel: buttonLabel,
              onButtonPressed: onButtonPressed,
              details: details,
            ),
          ),
        );
      },
    );
  }

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case CustomPopupType.success:
        return const Color(0xFF10B981); // Emerald Green
      case CustomPopupType.error:
        return const Color(0xFFEF4444); // Scarlet Red
      case CustomPopupType.warning:
        return const Color(0xFFF59E0B); // Amber Orange
      case CustomPopupType.info:
        return const Color(0xFF3B82F6); // Sleek Blue
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case CustomPopupType.success:
        return Icons.check_circle_outline_rounded;
      case CustomPopupType.error:
        return Icons.error_outline_rounded;
      case CustomPopupType.warning:
        return Icons.warning_amber_rounded;
      case CustomPopupType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = _getTypeColor();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing animated Icon at the top
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(
                        alpha: 0.2 + (_glowController.value * 0.4),
                      ),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(
                          alpha: 0.1 + (_glowController.value * 0.15),
                        ),
                        blurRadius: 12 + (_glowController.value * 8),
                        spreadRadius: 2 + (_glowController.value * 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    size: 32.sp,
                    color: primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Dialog Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Dialog Message
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                height: 1.4,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),

            // Details/Reasons list if present (e.g. registration failure details)
            if (widget.details != null && widget.details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.details!.map((detail) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_right_rounded,
                            size: 16.sp,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              detail,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Modern Primary Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onButtonPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.buttonLabel,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
