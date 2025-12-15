import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:claimflow_ai/theme.dart';
import 'package:claimflow_ai/models/claim.dart';
import 'package:claimflow_ai/services/claim_service.dart';
import 'package:claimflow_ai/components/glass_card.dart';

class ClaimsAnalyticsPage extends StatefulWidget {
  const ClaimsAnalyticsPage({super.key});

  @override
  State<ClaimsAnalyticsPage> createState() => _ClaimsAnalyticsPageState();
}

class _ClaimsAnalyticsPageState extends State<ClaimsAnalyticsPage> {
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

    final totalAmount = _claims.fold(0.0, (sum, c) => sum + c.amount);
    final avgAmount = _claims.isEmpty ? 0.0 : totalAmount / _claims.length;
    final maxAmount = _claims.isEmpty ? 0.0 : _claims.map((c) => c.amount).reduce((a, b) => a > b ? a : b);
    final minAmount = _claims.isEmpty ? 0.0 : _claims.map((c) => c.amount).reduce((a, b) => a < b ? a : b);

    final autoTotal = _claims.where((c) => c.type == 'Auto').fold(0.0, (sum, c) => sum + c.amount);
    final propertyTotal = _claims.where((c) => c.type == 'Property').fold(0.0, (sum, c) => sum + c.amount);
    final healthTotal = _claims.where((c) => c.type == 'Health').fold(0.0, (sum, c) => sum + c.amount);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Claims Analytics',
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Financial overview & claim value breakdown',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: AnalyticsSummaryCard(
                      title: 'Total Value',
                      value: '\$${NumberFormat.compact().format(totalAmount)}',
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalyticsSummaryCard(
                      title: 'Average',
                      value: '\$${NumberFormat.compact().format(avgAmount)}',
                      icon: Icons.analytics,
                      iconColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AnalyticsSummaryCard(
                      title: 'Highest',
                      value: '\$${NumberFormat.compact().format(maxAmount)}',
                      icon: Icons.arrow_upward,
                      iconColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalyticsSummaryCard(
                      title: 'Lowest',
                      value: '\$${NumberFormat.compact().format(minAmount)}',
                      icon: Icons.arrow_downward,
                      iconColor: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              Text(
                'Amount by Type',
                style: context.textStyles.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: [autoTotal, propertyTotal, healthTotal].reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.surface,
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final types = ['Auto', 'Property', 'Health'];
                            return BarTooltipItem(
                              '${types[groupIndex]}\n\$${NumberFormat.compact().format(rod.toY)}',
                              const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final titles = ['Auto', 'Property', 'Health'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  titles[value.toInt()],
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${NumberFormat.compact().format(value)}',
                                style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                              );
                            },
                            reservedSize: 50,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxAmount / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: autoTotal,
                              gradient: const LinearGradient(
                                colors: [AppColors.chartBlue, AppColors.primary],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 32,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: propertyTotal,
                              gradient: const LinearGradient(
                                colors: [AppColors.chartPurple, AppColors.accent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 32,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: healthTotal,
                              gradient: const LinearGradient(
                                colors: [AppColors.chartPink, AppColors.error],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 32,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              
              Text(
                'Top Claims by Value',
                style: context.textStyles.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...(_claims.toList()..sort((a, b) => b.amount.compareTo(a.amount)))
                  .take(5)
                  .map((claim) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TopClaimItem(claim: claim),
                      )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalyticsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const AnalyticsSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class TopClaimItem extends StatelessWidget {
  final Claim claim;

  const TopClaimItem({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(claim.type).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              _getTypeIcon(claim.type),
              color: _getTypeColor(claim.type),
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
                  style: context.textStyles.labelMedium?.copyWith(
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
          Text(
            '\$${NumberFormat('#,###').format(claim.amount)}',
            style: context.textStyles.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Auto':
        return AppColors.chartBlue;
      case 'Property':
        return AppColors.chartPurple;
      case 'Health':
        return AppColors.chartPink;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Auto':
        return Icons.directions_car;
      case 'Property':
        return Icons.home;
      case 'Health':
        return Icons.local_hospital;
      default:
        return Icons.description;
    }
  }
}
