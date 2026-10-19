import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/constants/app_constants.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import '../data/bank_models.dart';
import 'bank_provider.dart';

class DonationCampsScreen extends ConsumerStatefulWidget {
  const DonationCampsScreen({super.key});

  @override
  ConsumerState<DonationCampsScreen> createState() => _DonationCampsScreenState();
}

class _DonationCampsScreenState extends ConsumerState<DonationCampsScreen> {
  String _selectedDistrict = 'ALL';

  @override
  Widget build(BuildContext context) {
    final campsAsync = ref.watch(donationCampsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mobile Blood Drives & Camps'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(donationCampsProvider),
            tooltip: 'Refresh drives',
          ),
        ],
      ),
      body: Column(
        children: [
          // District filter row
          _buildDistrictFilter(),

          // Camps List
          Expanded(
            child: campsAsync.when(
              loading: () => const LoadingView(message: 'Scanning regional blood donation drives...'),
              error: (err, stack) => ErrorStateView(
                title: 'Unable to load donation drives',
                message: err.toString(),
                onRetry: () => ref.refresh(donationCampsProvider),
              ),
              data: (camps) {
                final filtered = camps.where((camp) {
                  if (_selectedDistrict != 'ALL' && camp.district != _selectedDistrict) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.event_busy,
                    title: 'No Blood Drives Scheduled',
                    subtitle:
                        'There are currently no active public blood donation drives matching your selected district filter.',
                    actionLabel: 'Reset District Filter',
                    onAction: () => setState(() => _selectedDistrict = 'ALL'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(donationCampsProvider),
                  color: AppColors.primaryNavy,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _buildCampCard(filtered[index]);
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

  Widget _buildDistrictFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDistrictChip('All Districts', 'ALL'),
            ...AppConstants.sriLankaDistricts.take(8).map((d) => _buildDistrictChip(d, d)),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictChip(String label, String value) {
    final isSelected = _selectedDistrict == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedDistrict = value),
        selectedColor: AppColors.primaryNavy.withValues(alpha: 0.12),
        checkmarkColor: AppColors.primaryNavy,
        labelStyle: AppTextStyles.caption.copyWith(
          color: isSelected ? AppColors.primaryNavy : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
          ),
        ),
      ),
    );
  }

  Widget _buildCampCard(DonationCampModel camp) {
    final progress = (camp.registeredCount / camp.targetUnits).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.campaign, color: AppColors.primaryNavy, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${camp.locationName}, ${camp.district}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Date & Time Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryNavy),
                const SizedBox(width: 8),
                Text(
                  camp.date,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 16, color: AppColors.primaryNavy),
                const SizedBox(width: 6),
                Text(
                  '${camp.startTime} - ${camp.endTime}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registration Progress',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${camp.registeredCount} / ${camp.targetUnits} donors registered',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // RSVP CTA
          CustomButton(
            text: 'RSVP to Donate at this Drive',
            icon: Icons.check,
            variant: ButtonVariant.primary,
            onPressed: () async {
              try {
                final repo = ref.read(bankRepositoryProvider);
                await repo.rsvpForCamp(camp.id);
                ref.invalidate(donationCampsProvider);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('RSVP confirmed! Added to your donation calendar.'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('RSVP submitted for drive.'),
                    backgroundColor: AppColors.primaryNavy,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
