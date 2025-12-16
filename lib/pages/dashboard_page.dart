import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:claimflow_ai/theme.dart';
import 'package:claimflow_ai/components/glass_card.dart';
import 'package:claimflow_ai/components/stat_card.dart';
import 'package:claimflow_ai/components/claim_card.dart';
import 'package:claimflow_ai/models/claim.dart';
import 'package:claimflow_ai/services/claim_service.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ClaimService _claimService = ClaimService();
  List<Claim> _claims = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() => _isLoading = true);
    _claims = await _claimService.getAllClaims();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalClaims = _claims.length;
    final avgAmount = _claims.isEmpty
        ? 0.0
        : _claims.map((c) => c.amount).reduce((a, b) => a + b) / _claims.length;
    final highRiskClaims =
        _claims.where((c) => (c.fraudScore ?? 0) > 0.5).length;
    final pendingClaims = _claims
        .where((c) =>
            c.status == 'Under Review' || c.status == 'Pending Documents')
        .length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'ClaimFlow AI demo',
                            style: context.textStyles.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enterprise Claims Intelligence',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Key Metrics',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: 'Total Claims',
                                value: totalClaims.toString(),
                                subtitle: 'Active this month',
                                icon: Icons.description,
                                iconColor: AppColors.primary,
                                trend: '+12%',
                                trendIsPositive: true,
                                onTap: () => context.push('/all-claims'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: 'Average Amount',
                                value:
                                    '\$${NumberFormat.compact().format(avgAmount)}',
                                subtitle: 'Per claim',
                                icon: Icons.attach_money,
                                iconColor: AppColors.accent,
                                trend: '-3%',
                                trendIsPositive: false,
                                onTap: () => context.push('/analytics'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: 'High Risk',
                                value: highRiskClaims.toString(),
                                subtitle: 'Fraud alerts',
                                icon: Icons.warning,
                                iconColor: AppColors.error,
                                trend: '-8%',
                                trendIsPositive: true,
                                onTap: () => context.push('/high-risk'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: StatCard(
                                title: 'Pending Review',
                                value: pendingClaims.toString(),
                                subtitle: 'Awaiting action',
                                icon: Icons.pending_actions,
                                iconColor: AppColors.warning,
                                trend: '+5%',
                                trendIsPositive: false,
                                onTap: () => context.push('/pending-review'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Claims by Type',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: ClaimTypeChart(claims: _claims),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Claims',
                            style: context.textStyles.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/all-claims'),
                          child: Text(
                            'View All',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClaimCard(
                        claim: _claims[index],
                        onTap: () =>
                            context.push('/claim/${_claims[index].id}'),
                      ),
                    );
                  },
                  childCount: _claims.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class ClaimTypeChart extends StatelessWidget {
  final List<Claim> claims;

  const ClaimTypeChart({super.key, required this.claims});

  @override
  Widget build(BuildContext context) {
    final autoClaims = claims.where((c) => c.type == 'Auto').length;
    final propertyClaims = claims.where((c) => c.type == 'Property').length;
    final healthClaims = claims.where((c) => c.type == 'Health').length;
    final total = claims.length;

    if (total == 0) {
      return Center(
        child: Text(
          'No data available',
          style: context.textStyles.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 280;

        if (isNarrow) {
          return Column(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                    sections: _buildSections(context, autoClaims,
                        propertyClaims, healthClaims, total, 45),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendChip(AppColors.chartBlue, 'Auto', autoClaims),
                  const SizedBox(width: 12),
                  _buildLegendChip(
                      AppColors.chartPurple, 'Property', propertyClaims),
                  const SizedBox(width: 12),
                  _buildLegendChip(AppColors.chartPink, 'Health', healthClaims),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildSections(context, autoClaims, propertyClaims,
                      healthClaims, total, 50),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(
                    color: AppColors.chartBlue,
                    label: 'Auto',
                    value: autoClaims.toString(),
                  ),
                  const SizedBox(height: 10),
                  LegendItem(
                    color: AppColors.chartPurple,
                    label: 'Property',
                    value: propertyClaims.toString(),
                  ),
                  const SizedBox(height: 10),
                  LegendItem(
                    color: AppColors.chartPink,
                    label: 'Health',
                    value: healthClaims.toString(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildSections(
    BuildContext context,
    int auto,
    int property,
    int health,
    int total,
    double radius,
  ) {
    return [
      PieChartSectionData(
        color: AppColors.chartBlue,
        value: auto.toDouble(),
        title: '${((auto / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: context.textStyles.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
      PieChartSectionData(
        color: AppColors.chartPurple,
        value: property.toDouble(),
        title: '${((property / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: context.textStyles.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
      PieChartSectionData(
        color: AppColors.chartPink,
        value: health.toDouble(),
        title: '${((health / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: context.textStyles.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    ];
  }

  Widget _buildLegendChip(Color color, String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($value)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: context.textStyles.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
