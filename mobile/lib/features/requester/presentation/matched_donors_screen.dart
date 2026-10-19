import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import '../data/request_models.dart';
import 'request_provider.dart';

class MatchedDonorsScreen extends ConsumerWidget {
  final String requestId;

  const MatchedDonorsScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(requestMatchesProvider(requestId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('AI Matched Donors'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(requestMatchesProvider(requestId)),
            tooltip: 'Refresh matches',
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const LoadingView(message: 'Neural Engine is matching nearby donors...'),
        error: (err, stack) => ErrorStateView(
          title: 'Unable to retrieve matches',
          message: err.toString(),
          onRetry: () => ref.refresh(requestMatchesProvider(requestId)),
        ),
        data: (matches) {
          if (matches.isEmpty) {
            return EmptyStateView(
              icon: Icons.radar,
              title: 'Searching for Donors...',
              subtitle:
                  'Our Neural Match Engine is actively broadcasting alerts to verified donors and blood banks in your vicinity.',
              actionLabel: 'Track Dispatch Progress',
              onAction: () => context.push('/tracking/$requestId'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Top Engine Status Banner
              _buildEngineBanner(matches.length),
              const SizedBox(height: 16),

              // Matched donor cards
              ...matches.map((match) => _buildDonorCard(context, match)),
              const SizedBox(height: 20),

              // Track dispatch button
              CustomButton(
                text: 'View Live Dispatch Timeline',
                icon: Icons.route,
                variant: ButtonVariant.primary,
                onPressed: () => context.push('/tracking/$requestId'),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEngineBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neural Match Engine',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count verified donor(s) ranked by compatibility & distance',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard(BuildContext context, DonorMatchModel match) {
    final hasAccepted = match.status.toUpperCase() == 'ACCEPTED' ||
        match.status.toUpperCase() == 'DISPATCHED' ||
        match.status.toUpperCase() == 'ARRIVED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAccepted ? AppColors.successGreen.withValues(alpha: 0.5) : AppColors.borderLight,
          width: hasAccepted ? 1.5 : 1,
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
          // Row: Avatar + Anonymous donor ID + Match Score badge
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    match.bloodType,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.accentCrimson,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.donorName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Identity protected per NBTS privacy standard',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 14, color: AppColors.successGreen),
                    const SizedBox(width: 2),
                    Text(
                      '${match.matchPercent}% Fit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Proximity & ETA breakdown
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCol(
                  'Distance',
                  match.distanceKm != null ? '${match.distanceKm!.toStringAsFixed(1)} km' : 'Within 5 km',
                ),
                Container(width: 1, height: 24, color: AppColors.borderLight),
                _buildInfoCol(
                  'Estimated ETA',
                  match.etaMinutes != null ? '~${match.etaMinutes} mins' : 'Calculating...',
                ),
                Container(width: 1, height: 24, color: AppColors.borderLight),
                _buildInfoCol('Status', match.status),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action row matching Main-5.png
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final phoneParam = match.contactPhone ?? '+94 71 456 7890';
                      context.push('/contact?name=${Uri.encodeComponent(match.donorName)}&phone=${Uri.encodeComponent(phoneParam)}');
                    },
                    icon: const Icon(Icons.call_rounded, size: 18, color: Colors.white),
                    label: Text(
                      'Contact ${match.donorName.split(' ').first}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF084B8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F2FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF084B8A)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing donor profile for ${match.donorName}')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
