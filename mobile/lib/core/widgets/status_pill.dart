import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PillVariant { pending, approved, critical, urgent, neutral, ai }

class StatusPill extends StatelessWidget {
  final String? label;
  final String? status;
  final PillVariant? variant;
  final bool showDot;

  const StatusPill({
    super.key,
    this.label,
    this.status,
    this.variant,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? status ?? 'STATUS';

    PillVariant resolvedVariant = variant ?? PillVariant.neutral;
    if (variant == null) {
      final upper = displayLabel.toUpperCase();
      if (upper.contains('CRITICAL') || upper.contains('REJECTED')) {
        resolvedVariant = PillVariant.critical;
      } else if (upper.contains('URGENT') || upper.contains('AMBER')) {
        resolvedVariant = PillVariant.urgent;
      } else if (upper.contains('APPROVED') ||
          upper.contains('SAFE') ||
          upper.contains('ACCEPTED') ||
          upper.contains('COMPLETED') ||
          upper.contains('DELIVERED') ||
          upper.contains('VERIFIED') ||
          upper.contains('FULFILLED')) {
        resolvedVariant = PillVariant.approved;
      } else if (upper.contains('PENDING') ||
          upper.contains('SCHEDULED') ||
          upper.contains('NOTIFIED') ||
          upper.contains('MATCHED') ||
          upper.contains('DISPATCHED') ||
          upper.contains('IN_TRANSIT')) {
        resolvedVariant = PillVariant.pending;
      } else if (upper.contains('AI') || upper.contains('NEURAL')) {
        resolvedVariant = PillVariant.ai;
      }
    }

    Color bg;
    Color text;
    Color dot;

    switch (resolvedVariant) {
      case PillVariant.pending:
        bg = AppColors.badgePendingBg;
        text = AppColors.badgePendingText;
        dot = const Color(0xFF3182CE);
        break;
      case PillVariant.approved:
        bg = AppColors.badgeApprovedBg;
        text = AppColors.badgeApprovedText;
        dot = AppColors.lifeGreen;
        break;
      case PillVariant.critical:
        bg = AppColors.badgeCriticalBg;
        text = AppColors.badgeCriticalText;
        dot = AppColors.criticalRed;
        break;
      case PillVariant.urgent:
        bg = AppColors.amberWarningLight;
        text = AppColors.amberWarning;
        dot = AppColors.amberWarning;
        break;
      case PillVariant.ai:
        bg = AppColors.aiLight;
        text = AppColors.aiIntelligence;
        dot = AppColors.aiIntelligence;
        break;
      case PillVariant.neutral:
        bg = AppColors.primaryLight;
        text = AppColors.primaryDark;
        dot = AppColors.primaryMain;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            displayLabel,
            style: AppTextStyles.caption.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
