import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import 'package:bloodlink_mobile/core/widgets/status_pill.dart';
import '../data/bank_models.dart';
import 'bank_provider.dart';

class IncomingDonorsScreen extends ConsumerStatefulWidget {
  const IncomingDonorsScreen({super.key});

  @override
  ConsumerState<IncomingDonorsScreen> createState() => _IncomingDonorsScreenState();
}

class _IncomingDonorsScreenState extends ConsumerState<IncomingDonorsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(bankDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Incoming Donors Verification'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(bankDashboardProvider),
            tooltip: 'Refresh queue',
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const LoadingView(message: 'Loading scheduled donor intake queue...'),
        error: (err, stack) => ErrorStateView(
          title: 'Unable to load donor arrivals',
          message: err.toString(),
          onRetry: () => ref.refresh(bankDashboardProvider),
        ),
        data: (data) {
          final donors = data.incomingDonors.where((d) {
            if (_searchQuery.isEmpty) return true;
            return d.donorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                d.bloodType.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search donor name or blood group...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Donors List
              Expanded(
                child: donors.isEmpty
                    ? EmptyStateView(
                        icon: Icons.people_outline,
                        title: 'No Incoming Donors Queued',
                        subtitle:
                            'Donors who accept emergency dispatches or book appointments through the BloodLink app will appear here for physical check-in and blood bag barcode verification.',
                        actionLabel: 'Refresh Queue',
                        onAction: () => ref.refresh(bankDashboardProvider),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.refresh(bankDashboardProvider),
                        color: AppColors.primaryNavy,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: donors.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildDonorCard(donors[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDonorCard(IncomingDonorModel donor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentCrimson.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    donor.bloodType,
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
                    Text(
                      donor.donorName,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      donor.timeSlot ?? 'Arrival in progress',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusPill(status: donor.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Verify Arrival & Bag Barcode',
                  icon: Icons.check_circle_outline,
                  variant: ButtonVariant.success,
                  onPressed: () => _showVerifyDialog(context, donor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context, IncomingDonorModel donor) {
    final barcodeController = TextEditingController(
      text: 'LK-NBTS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    int volumeMl = 450;
    bool isSubmitting = false;

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
                  Text('Verify Donor Arrival', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Donor: ${donor.donorName} (${donor.bloodType})',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  // Volume Selection
                  Text('Collected Blood Volume:', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [350, 450, 500].map((vol) {
                      final isSelected = volumeMl == vol;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$vol mL'),
                          selected: isSelected,
                          selectedColor: AppColors.primaryNavy.withValues(alpha: 0.15),
                          onSelected: (_) => setModalState(() => volumeMl = vol),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Bag Barcode
                  Text('Blood Bag Barcode Identifier *', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. LK-NBTS-94821',
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
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
                          text: 'Confirm Intake',
                          variant: ButtonVariant.success,
                          isLoading: isSubmitting,
                          onPressed: () async {
                            final barcode = barcodeController.text.trim();
                            if (barcode.isEmpty) return;

                            setModalState(() => isSubmitting = true);
                            try {
                              final repo = ref.read(bankRepositoryProvider);
                              await repo.verifyDonationArrival(
                                donationId: donor.donationId,
                                volumeMl: volumeMl,
                                bloodBagBarcode: barcode,
                              );
                              ref.invalidate(bankDashboardProvider);
                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Donation verified! Bag $barcode logged to inventory.'),
                                    backgroundColor: AppColors.successGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Verification error: ${e.toString()}'),
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
