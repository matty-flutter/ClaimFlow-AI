import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:claimflow_ai/theme.dart';
import 'package:claimflow_ai/models/claim.dart';
import 'package:claimflow_ai/services/claim_service.dart';
import 'package:claimflow_ai/components/glass_card.dart';

class PendingReviewPage extends StatefulWidget {
  const PendingReviewPage({super.key});

  @override
  State<PendingReviewPage> createState() => _PendingReviewPageState();
}

class _PendingReviewPageState extends State<PendingReviewPage> with SingleTickerProviderStateMixin {
  final ClaimService _claimService = ClaimService();
  List<Claim> _pendingClaims = [];
  bool _isLoading = true;
  late TabController _tabController;

  final List<String> _pendingStatuses = ['Under Review', 'Pending Documents', 'Investigating'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClaims();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClaims() async {
    setState(() => _isLoading = true);
    final allClaims = await _claimService.getAllClaims();
    _pendingClaims = allClaims.where((c) => _pendingStatuses.contains(c.status)).toList();
    _pendingClaims.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    setState(() => _isLoading = false);
  }

  List<Claim> _getClaimsByStatus(String status) {
    return _pendingClaims.where((c) => c.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final underReview = _getClaimsByStatus('Under Review');
    final pendingDocs = _getClaimsByStatus('Pending Documents');
    final investigating = _getClaimsByStatus('Investigating');

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pending Review',
                                style: context.textStyles.headlineMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.pending_actions, size: 14, color: AppColors.warning),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_pendingClaims.length} pending',
                                    style: context.textStyles.labelMedium?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Claims awaiting action or additional information',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Review'),
                              const SizedBox(width: 6),
                              _buildBadge(underReview.length, AppColors.primary),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Docs'),
                              const SizedBox(width: 6),
                              _buildBadge(pendingDocs.length, AppColors.accent),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Invest.'),
                              const SizedBox(width: 6),
                              _buildBadge(investigating.length, AppColors.warning),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PendingClaimsList(
                          claims: underReview,
                          emptyMessage: 'No claims under review',
                          emptyIcon: Icons.check_circle,
                        ),
                        PendingClaimsList(
                          claims: pendingDocs,
                          emptyMessage: 'No pending documents',
                          emptyIcon: Icons.folder_open,
                        ),
                        PendingClaimsList(
                          claims: investigating,
                          emptyMessage: 'No active investigations',
                          emptyIcon: Icons.search_off,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PendingClaimsList extends StatelessWidget {
  final List<Claim> claims;
  final String emptyMessage;
  final IconData emptyIcon;

  const PendingClaimsList({
    super.key,
    required this.claims,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (claims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(emptyIcon, size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: context.textStyles.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great job staying on top of claims!',
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: claims.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PendingClaimCard(
            claim: claims[index],
            onTap: () => context.push('/claim/${claims[index].id}'),
          ),
        );
      },
    );
  }
}

class PendingClaimCard extends StatelessWidget {
  final Claim claim;
  final VoidCallback? onTap;

  const PendingClaimCard({
    super.key,
    required this.claim,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysPending = DateTime.now().difference(claim.updatedAt).inDays;
    final isUrgent = daysPending > 5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(claim.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      _getStatusIcon(claim.status),
                      color: _getStatusColor(claim.status),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.claimNumber,
                          style: context.textStyles.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUrgent ? AppColors.error.withValues(alpha: 0.15) : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: isUrgent ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isUrgent) ...[
                              const Icon(Icons.schedule, size: 10, color: AppColors.error),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '${daysPending}d ago',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: isUrgent ? AppColors.error : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InfoChip(
                      icon: Icons.category,
                      label: claim.type,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoChip(
                      icon: Icons.attach_money,
                      label: '\$${NumberFormat.compact().format(claim.amount)}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (claim.assignedAdjuster != null)
                    Expanded(
                      child: InfoChip(
                        icon: Icons.person,
                        label: claim.assignedAdjuster!.name.split(' ').first,
                      ),
                    ),
                ],
              ),
              if (claim.aiRecommendations != null && claim.aiRecommendations!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Next: ${claim.aiRecommendations!.first}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Under Review':
        return AppColors.primary;
      case 'Pending Documents':
        return AppColors.accent;
      case 'Investigating':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Under Review':
        return Icons.rate_review;
      case 'Pending Documents':
        return Icons.folder;
      case 'Investigating':
        return Icons.search;
      default:
        return Icons.pending;
    }
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: context.textStyles.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
