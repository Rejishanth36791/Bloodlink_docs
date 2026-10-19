import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/constants/app_constants.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import 'package:bloodlink_mobile/core/widgets/status_pill.dart';
import '../data/donor_models.dart';
import 'donor_provider.dart';

class UrgentAppealsScreen extends ConsumerStatefulWidget {
  const UrgentAppealsScreen({super.key});

  @override
  ConsumerState<UrgentAppealsScreen> createState() => _UrgentAppealsScreenState();
}

class _UrgentAppealsScreenState extends ConsumerState<UrgentAppealsScreen> {
  String _selectedBloodFilter = 'ALL';
  String _selectedUrgencyFilter = 'ALL';
  double _maxDistanceKm = 50.0;

  @override
  Widget build(BuildContext context) {
    final appealsAsync = ref.watch(nearbyAppealsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Urgent Blood Appeals'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(nearbyAppealsProvider),
            tooltip: 'Refresh appeals',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Section
          _buildFilterBar(),

          // Appeals List
          Expanded(
            child: appealsAsync.when(
              loading: () => const LoadingView(message: 'Scanning regional appeals...'),
              error: (err, stack) => ErrorStateView(
                title: 'Unable to load appeals',
                message: err.toString(),
                onRetry: () => ref.refresh(nearbyAppealsProvider),
              ),
              data: (appeals) {
                final filtered = appeals.where((appeal) {
                  if (_selectedBloodFilter != 'ALL' &&
                      appeal.bloodType != _selectedBloodFilter) {
                    return false;
                  }
                  if (_selectedUrgencyFilter != 'ALL' &&
                      appeal.urgency.toUpperCase() != _selectedUrgencyFilter) {
                    return false;
                  }
                  if (appeal.distanceKm != null &&
                      appeal.distanceKm! > _maxDistanceKm) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.check_circle_outline,
                    title: 'No Active Appeals',
                    subtitle:
                        'There are currently no urgent blood requests matching your filters within ${_maxDistanceKm.toInt()} km.',
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      setState(() {
                        _selectedBloodFilter = 'ALL';
                        _selectedUrgencyFilter = 'ALL';
                        _maxDistanceKm = 50.0;
                      });
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(nearbyAppealsProvider),
                  color: AppColors.primaryNavy,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildAppealCard(filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filters',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Radius: ${_maxDistanceKm.toInt()} km',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Blood Types', 'ALL', _selectedBloodFilter, (val) {
                  setState(() => _selectedBloodFilter = val);
                }),
                ...AppConstants.bloodTypes.map((type) => _buildFilterChip(
                      type,
                      type,
                      _selectedBloodFilter,
                      (val) => setState(() => _selectedBloodFilter = val),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Urgency', 'ALL', _selectedUrgencyFilter, (val) {
                  setState(() => _selectedUrgencyFilter = val);
                }),
                _buildFilterChip('Critical', 'CRITICAL', _selectedUrgencyFilter, (val) {
                  setState(() => _selectedUrgencyFilter = val);
                }),
                _buildFilterChip('Urgent', 'URGENT', _selectedUrgencyFilter, (val) {
                  setState(() => _selectedUrgencyFilter = val);
                }),
                _buildFilterChip('Normal', 'NORMAL', _selectedUrgencyFilter, (val) {
                  setState(() => _selectedUrgencyFilter = val);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == currentValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: AppColors.primaryNavy.withValues(alpha: 0.12),
        checkmarkColor: AppColors.primaryNavy,
        labelStyle: AppTextStyles.caption.copyWith(
          color: isSelected ? AppColors.primaryNavy : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
          ),
        ),
      ),
    );
  }

  Widget _buildAppealCard(AppealModel appeal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appeal.urgency.toUpperCase() == 'CRITICAL'
              ? AppColors.accentCrimson.withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentCrimson.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    appeal.bloodType,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.accentCrimson,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusPill(status: appeal.urgency),
                        const Spacer(),
                        if (appeal.distanceKm != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.primaryNavy),
                              const SizedBox(width: 2),
                              Text(
                                '${appeal.distanceKm!.toStringAsFixed(1)} km',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appeal.hospitalName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (appeal.district != null)
                      Text(
                        appeal.district!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, size: 16, color: AppColors.accentCrimson),
                    const SizedBox(width: 6),
                    Text(
                      'Units Needed: ${appeal.unitsNeeded}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (appeal.etaMinutes != null)
                  Text(
                    'ETA: ~${appeal.etaMinutes} mins',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Respond as Donor',
                  icon: Icons.volunteer_activism,
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    _showRespondDialog(context, appeal);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRespondDialog(BuildContext context, AppealModel appeal) {
    int selectedEta = 30;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_hospital, color: AppColors.primaryNavy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Confirm Donation Dispatch', style: AppTextStyles.titleMedium),
                            Text(appeal.hospitalName, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Text(
                    'Required Blood Group: ${appeal.bloodType} (${appeal.unitsNeeded} units)',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select your estimated arrival time (ETA):',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: selectedEta.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    label: '$selectedEta mins',
                    activeColor: AppColors.primaryNavy,
                    onChanged: (val) {
                      setModalState(() => selectedEta = val.toInt());
                    },
                  ),
                  Center(
                    child: Text(
                      'Estimated Arrival: $selectedEta minutes',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          variant: ButtonVariant.secondary,
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Confirm Dispatch',
                          variant: ButtonVariant.success,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            try {
                              final repo = ref.read(donorRepositoryProvider);
                              await repo.acceptMatch(
                                matchId: appeal.id,
                                etaMinutes: selectedEta,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Donation confirmed! Navigating to live dispatch.'),
                                    backgroundColor: AppColors.successGreen,
                                  ),
                                );
                                context.push('/tracking/${appeal.id}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: AppColors.accentCrimson,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
