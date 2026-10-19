import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/storage/token_storage.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import 'package:bloodlink_mobile/core/widgets/status_pill.dart';
import '../data/bank_models.dart';
import 'bank_provider.dart';

class BloodBankDashboardScreen extends ConsumerWidget {
  const BloodBankDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(bankDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('NBTS Clinical Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(bankDashboardProvider),
            tooltip: 'Refresh inventory',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accentCrimson),
            onPressed: () => _confirmSignOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const LoadingView(message: 'Loading live blood bank matrix & forecasts...'),
        error: (err, stack) => ErrorStateView(
          title: 'Unable to connect to Blood Bank service',
          message: err.toString(),
          onRetry: () => ref.refresh(bankDashboardProvider),
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(bankDashboardProvider),
            color: AppColors.primaryNavy,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Facility Header
                _buildFacilityBanner(data),
                const SizedBox(height: 16),

                // Metrics Row: Total Units, Quota, Dispatches
                _buildMetricsRow(data),
                const SizedBox(height: 20),

                // AI Demand Forecast Warning
                if (data.forecasts.isNotEmpty) ...[
                  _buildAiForecastBanner(data.forecasts.first),
                  const SizedBox(height: 20),
                ],

                // Live 8-Group Blood Matrix Section
                Text(
                  'Live Blood Matrix (Whole Blood & PRBC)',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBloodMatrixGrid(data.bloodMatrix),
                const SizedBox(height: 24),

                // Quick Clinical Operations
                Text(
                  'Facility Management Operations',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOperationsGrid(context),
                const SizedBox(height: 24),

                // Incoming Donors Section
                Row(
                  children: [
                    Text(
                      'Scheduled Incoming Donors',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/bank-incoming-donors'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.incomingDonors.isEmpty)
                  _buildEmptyDonorsBanner()
                else
                  ...data.incomingDonors.map((donor) => _buildDonorTile(context, donor)),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacilityBanner(BankDashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital, color: AppColors.primaryNavy, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.bankName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Facility: ${data.facilityType} | MOH Verified Center',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BankDashboardModel data) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            '${data.totalUnits}',
            'Total Units',
            Icons.bloodtype,
            AppColors.accentCrimson,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            '${data.dailyQuotaMet}%',
            'Daily Quota',
            Icons.pie_chart,
            AppColors.primaryNavy,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            '${data.activeDispatches}',
            'Dispatches',
            Icons.local_shipping,
            AppColors.secondaryTeal,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAiForecastBanner(DemandForecastModel forecast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_graph, color: Color(0xFFF57F17), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Stock Deficit Forecast: ${forecast.bloodType}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast.recommendation,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Projected run-out in ${forecast.predictedShortageDays} days (Confidence: ${forecast.confidencePercent.toInt()}%)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodMatrixGrid(List<InventoryItemModel> matrix) {
    if (matrix.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: Text('Inventory ledger is empty. Tap below to adjust stock.'),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: matrix.length,
      itemBuilder: (context, index) {
        final item = matrix[index];
        final isCritical = item.status.toUpperCase() == 'CRITICAL';
        final isAmber = item.status.toUpperCase() == 'AMBER';

        Color badgeColor = AppColors.successGreen;
        if (isCritical) badgeColor = AppColors.accentCrimson;
        if (isAmber) badgeColor = Colors.orange;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCritical ? AppColors.accentCrimson : AppColors.borderLight,
              width: isCritical ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.bloodType,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.unitsAvailable} u',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: AppTextStyles.caption.copyWith(
                    color: badgeColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOperationsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Adjust Stock Ledger',
            icon: Icons.edit_note,
            variant: ButtonVariant.primary,
            onPressed: () => context.push('/bank-inventory'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            text: 'Verify Incoming',
            icon: Icons.qr_code_scanner,
            variant: ButtonVariant.secondary,
            onPressed: () => context.push('/bank-incoming-donors'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDonorsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(
        child: Text(
          'No scheduled donor arrivals currently queued.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDonorTile(BuildContext context, IncomingDonorModel donor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentCrimson.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                donor.bloodType,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentCrimson,
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
                  donor.donorName,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  donor.timeSlot ?? 'Arrival Pending',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusPill(status: donor.status),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Blood Bank Sign Out'),
        content: const Text('Do you want to log out of the NBTS Clinical Dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final storage = TokenStorage();
              await storage.clearAll();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.accentCrimson)),
          ),
        ],
      ),
    );
  }
}
