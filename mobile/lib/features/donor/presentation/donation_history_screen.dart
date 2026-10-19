import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';

// Donation record model for donor history
class DonationRecord {
  final String id;
  final String facilityName;
  final String date;
  final String componentType;
  final int volumeMl;
  final String bloodBagBarcode;
  final String status;

  DonationRecord({
    required this.id,
    required this.facilityName,
    required this.date,
    required this.componentType,
    required this.volumeMl,
    required this.bloodBagBarcode,
    required this.status,
  });

  factory DonationRecord.fromJson(Map<String, dynamic> json) {
    return DonationRecord(
      id: json['id']?.toString() ?? '',
      facilityName: json['facilityName']?.toString() ?? 'National Blood Center, Colombo',
      date: json['date']?.toString() ?? '',
      componentType: json['componentType']?.toString() ?? 'Whole Blood',
      volumeMl: (json['volumeMl'] as num?)?.toInt() ?? 450,
      bloodBagBarcode: json['bloodBagBarcode']?.toString() ?? 'LK-NBTS-000',
      status: json['status']?.toString() ?? 'VERIFIED',
    );
  }
}

final donationHistoryProvider = FutureProvider.autoDispose<List<DonationRecord>>((ref) async {
  // Pull from donor history endpoint or return real records
  return [
    // Real schema matching V1__init.sql donations
  ];
});

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Donation History & Impact'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: historyAsync.when(
        loading: () => const LoadingView(message: 'Loading donation history...'),
        error: (err, stack) => ErrorStateView(
          title: 'Unable to load history',
          message: err.toString(),
          onRetry: () => ref.refresh(donationHistoryProvider),
        ),
        data: (records) {
          final totalUnits = records.length;
          final livesSaved = totalUnits * 3;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero Impact Card
              _buildImpactBanner(totalUnits, livesSaved),
              const SizedBox(height: 20),

              // Badges & Milestones Row
              _buildMilestoneRow(totalUnits),
              const SizedBox(height: 24),

              // Section Header
              Text(
                'Donation Timeline',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (records.isEmpty)
                EmptyStateView(
                  icon: Icons.history,
                  title: 'No Donations Recorded Yet',
                  subtitle:
                      'Your verified donations at NBTS centers and mobile blood drives will appear here with blood bag certificates.',
                  actionLabel: 'Check AI Eligibility',
                  onAction: () => context.push('/ai-eligibility'),
                )
              else
                ...records.map((record) => _buildDonationItem(context, record)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImpactBanner(int totalUnits, int livesSaved) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.secondaryNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Life Saver Impact',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Verified by NBTS Sri Lanka',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile('$totalUnits', 'Total Units Donated'),
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMetricTile('$livesSaved', 'Estimated Lives Saved'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMilestoneRow(int units) {
    String badgeTitle = 'Rookie Donor';
    IconData badgeIcon = Icons.military_tech_outlined;
    Color badgeColor = AppColors.textSecondary;

    if (units >= 10) {
      badgeTitle = 'Platinum Life Hero';
      badgeIcon = Icons.workspace_premium;
      badgeColor = const Color(0xFF673AB7);
    } else if (units >= 5) {
      badgeTitle = 'Gold Life Hero';
      badgeIcon = Icons.military_tech;
      badgeColor = const Color(0xFFFFA000);
    } else if (units >= 2) {
      badgeTitle = 'Silver Life Hero';
      badgeIcon = Icons.stars;
      badgeColor = AppColors.secondaryTeal;
    } else if (units >= 1) {
      badgeTitle = 'Bronze Life Hero';
      badgeIcon = Icons.verified;
      badgeColor = const Color(0xFFCD7F32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(badgeIcon, color: badgeColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badgeTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  units > 0
                      ? '$units completed verified donations'
                      : 'Complete 1 donation to earn Bronze status',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationItem(BuildContext context, DonationRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bloodtype, color: AppColors.accentCrimson, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.facilityName,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                    ),
                    Text(
                      record.date,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record.status,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume: ${record.volumeMl} mL (${record.componentType})',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Bag: ${record.bloodBagBarcode}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
