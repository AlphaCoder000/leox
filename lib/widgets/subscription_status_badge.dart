import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../providers/subscription_provider.dart';

class SubscriptionStatusBadge extends StatelessWidget {
  const SubscriptionStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final sub = subProvider.currentSubscription;

    if (sub == null) {
      return _buildBadge(
        text: "NO PLAN",
        color: Colors.grey,
        icon: Icons.star_border_rounded,
      );
    }

    if (sub.status == 'cancelled') {
      return _buildBadge(
        text: "CANCELLED",
        color: Colors.red,
        icon: Icons.cancel_outlined,
      );
    }

    if (sub.status == 'suspended') {
      return _buildBadge(
        text: "SUSPENDED",
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }

    if (sub.status == 'expired' || !sub.isActive) {
      return _buildBadge(
        text: "EXPIRED",
        color: Colors.red,
        icon: Icons.timer_off_outlined,
      );
    }

    if (sub.status == 'trial') {
      return _buildBadge(
        text: "FREE 1 MONTH",
        color: Colors.green,
        icon: Icons.workspace_premium_outlined,
      );
    }

    // Active premium
    return _buildBadge(
      text: "PREMIUM",
      color: Colors.amber,
      icon: Icons.star_rounded,
      iconColor: Colors.amber[700],
      textColor: Colors.amber[700],
    );
  }

  Widget _buildBadge({
    required String text,
    required Color color,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              color: textColor ?? color,
            ),
          ),
        ],
      ),
    );
  }
}
