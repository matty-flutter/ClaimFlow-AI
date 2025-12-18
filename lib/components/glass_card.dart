import 'package:flutter/material.dart';
import 'package:claimflow_ai/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool showBorder;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(8, -8),
          ),
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(8, 8),
          ),
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(-8, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
