import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:claimflow_ai/theme.dart';
import 'package:claimflow_ai/models/claim.dart';

class ClaimCard extends StatelessWidget {
  final Claim claim;
  final VoidCallback? onTap;

  const ClaimCard({
    super.key,
    required this.claim,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (claim.status) {
      case 'Approved':
        return AppColors.success;
      case 'Under Review':
        return AppColors.warning;
      case 'Investigating':
        return AppColors.error;
      case 'Pending Documents':
        return AppColors.accent;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getTypeIcon() {
    switch (claim.type) {
      case 'Auto':
        return Icons.directions_car;
      case 'Property':
        return Icons.home;
      case 'Health':
        return Icons.medical_services;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.claimNumber,
                        style: context.textStyles.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        claim.claimant.name,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      claim.status,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              claim.description,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    formatter.format(claim.amount),
                    style: context.textStyles.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (claim.fraudScore != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.security,
                    size: 14,
                    color: claim.fraudScore! > 0.5 ? AppColors.error : AppColors.success,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      'Risk: ${(claim.fraudScore! * 100).toStringAsFixed(0)}%',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: claim.fraudScore! > 0.5 ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
