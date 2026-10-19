import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import 'package:bloodlink_mobile/core/widgets/status_pill.dart';
import '../data/donor_models.dart';
import 'donor_provider.dart';

class DonorAlertsScreen extends ConsumerWidget {
  const DonorAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(donorAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Urgent Match Alerts'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(donorAlertsProvider),
            tooltip: 'Refresh alerts',
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const LoadingView(message: 'Checking for emergency match requests...'),
        error: (err, stack) => ErrorStateView(
          title: 'Unable to load alerts',
          message: err.toString(),
          onRetry: () => ref.refresh(donorAlertsProvider),
        ),
        data: (alerts) {
          if (alerts.isEmpty) {
            return EmptyStateView(
              icon: Icons.notifications_none,
              title: 'No Incoming Dispatch Alerts',
              subtitle:
                  'You will receive instant push notifications when a hospital within your radius requests ${'blood matching your profile'}.',
              actionLabel: 'View All Regional Appeals',
              onAction: () => context.push('/appeals'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(donorAlertsProvider),
            color: AppColors.primaryNavy,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildAlertCard(context, ref, alerts[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, MatchAlertModel alert) {
    final matchPercent = (alert.totalScore * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alert.urgency.toUpperCase() == 'CRITICAL'
              ? AppColors.accentCrimson
              : AppColors.primaryNavy.withValues(alpha: 0.3),
          width: alert.urgency.toUpperCase() == 'CRITICAL' ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: alert.urgency.toUpperCase() == 'CRITICAL'
                ? AppColors.accentCrimson.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, size: 14, color: AppColors.accentCrimson),
                    const SizedBox(width: 4),
                    Text(
                      'AI NEURAL MATCH',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCrimson,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              StatusPill(status: alert.urgency),
            ],
          ),
          const SizedBox(height: 14),

          // Main Hospital and Group
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    alert.bloodType,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primaryNavy,
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
                      alert.hospitalName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alert.unitsNeeded} unit(s) urgently requested',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // AI Metrics Matrix
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol('Overall Fit', '$matchPercent%', AppColors.successGreen),
                Container(width: 1, height: 28, color: AppColors.borderLight),
                _buildMetricCol(
                  'Compatibility',
                  '${(alert.compatibilityScore * 100).toInt()}%',
                  AppColors.primaryNavy,
                ),
                Container(width: 1, height: 28, color: AppColors.borderLight),
                _buildMetricCol(
                  'Proximity',
                  '${(alert.proximityScore * 100).toInt()}%',
                  AppColors.secondaryTeal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: Accept / Decline
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Decline',
                  variant: ButtonVariant.secondary,
                  onPressed: () async {
                    try {
                      final repo = ref.read(donorRepositoryProvider);
                      await repo.declineMatch(alert.id);
                      ref.invalidate(donorAlertsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Match alert declined.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Accept Dispatch',
                  icon: Icons.check,
                  variant: ButtonVariant.success,
                  onPressed: () {
                    _showAcceptModal(context, ref, alert);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  void _showAcceptModal(BuildContext context, WidgetRef ref, MatchAlertModel alert) {
    int etaMinutes = 30;

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
                  Text('Confirm Dispatch to Hospital', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'You are confirming departure to ${alert.hospitalName}. Please choose your estimated arrival time:',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: etaMinutes.toDouble(),
                    min: 15,
                    max: 90,
                    divisions: 5,
                    label: '$etaMinutes mins',
                    activeColor: AppColors.primaryNavy,
                    onChanged: (v) => setModalState(() => etaMinutes = v.toInt()),
                  ),
                  Center(
                    child: Text(
                      '$etaMinutes minutes arrival time',
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
                          text: 'Confirm & Go',
                          variant: ButtonVariant.success,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            try {
                              final repo = ref.read(donorRepositoryProvider);
                              await repo.acceptMatch(
                                matchId: alert.id,
                                etaMinutes: etaMinutes,
                              );
                              ref.invalidate(donorAlertsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Accepted! Dispatch route initialized.'),
                                    backgroundColor: AppColors.successGreen,
                                  ),
                                );
                                context.push('/tracking/${alert.requestId}');
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
