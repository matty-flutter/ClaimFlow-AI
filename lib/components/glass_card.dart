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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        border: showBorder
            ? Border.all(
                color: borderColor ?? (isDark ? AppColors.border : const Color(0xFFE2E8F0)),
                width: 1,
              )
            : null,
      ),
      child: child,
    );
  }
}
