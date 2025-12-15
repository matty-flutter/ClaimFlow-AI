import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:claimflow_ai/theme.dart';
import 'package:claimflow_ai/models/claim.dart';
import 'package:claimflow_ai/services/claim_service.dart';
import 'package:claimflow_ai/components/claim_card.dart';

class AllClaimsPage extends StatefulWidget {
  const AllClaimsPage({super.key});

  @override
  State<AllClaimsPage> createState() => _AllClaimsPageState();
}

class _AllClaimsPageState extends State<AllClaimsPage> {
  final ClaimService _claimService = ClaimService();
  List<Claim> _allClaims = [];
  List<Claim> _filteredClaims = [];
  bool _isLoading = true;
  
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  
  final List<String> _types = ['All', 'Auto', 'Property', 'Health'];
  final List<String> _statuses = ['All', 'Under Review', 'Approved', 'Pending Documents', 'Investigating', 'Denied'];

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() => _isLoading = true);
    _allClaims = await _claimService.getAllClaims();
    _applyFilters();
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _filteredClaims = _allClaims.where((claim) {
      final matchesType = _selectedType == 'All' || claim.type == _selectedType;
      final matchesStatus = _selectedStatus == 'All' || claim.status == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          claim.claimNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          claim.claimant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          claim.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                          'All Claims',
                          style: context.textStyles.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          '${_filteredClaims.length} claims',
                          style: context.textStyles.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search claims...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipGroup(
                          label: 'Type',
                          options: _types,
                          selected: _selectedType,
                          onSelected: (value) {
                            setState(() {
                              _selectedType = value;
                              _applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        FilterChipGroup(
                          label: 'Status',
                          options: _statuses,
                          selected: _selectedStatus,
                          onSelected: (value) {
                            setState(() {
                              _selectedStatus = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClaims.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
                              const SizedBox(height: 16),
                              Text(
                                'No claims found',
                                style: context.textStyles.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: context.textStyles.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredClaims.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ClaimCard(
                                claim: _filteredClaims[index],
                                onTap: () => context.push('/claim/${_filteredClaims[index].id}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 40),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (context) => options.map((option) {
        final isSelected = option == selected;
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check, size: 16, color: AppColors.primary)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(
                option,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected != 'All' ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected != 'All' ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selected',
              style: context.textStyles.labelMedium?.copyWith(
                color: selected != 'All' ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: selected != 'All' ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
