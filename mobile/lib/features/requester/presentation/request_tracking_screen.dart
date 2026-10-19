import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import 'package:bloodlink_mobile/core/widgets/status_pill.dart';
import '../data/request_models.dart';
import 'request_provider.dart';

class RequestTrackingScreen extends ConsumerWidget {
  final String requestId;

  const RequestTrackingScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(requestDetailProvider(requestId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Live Dispatch Tracking'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryNavy),
            onPressed: () => ref.refresh(requestDetailProvider(requestId)),
            tooltip: 'Refresh tracking telemetry',
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const LoadingView(message: 'Connecting to live dispatch telemetry...'),
        error: (err, stack) => ErrorStateView(
          title: 'Unable to load tracking',
          message: err.toString(),
          onRetry: () => ref.refresh(requestDetailProvider(requestId)),
        ),
        data: (request) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Live Status Header Banner
              _buildLiveEtaBanner(request),
              const SizedBox(height: 16),

              // Cold-Chain Telemetry Card (Mockup 4)
              _buildColdChainCard(),
              const SizedBox(height: 20),

              // 5-Stage Dispatch Timeline
              _buildTimelineSection(request),
              const SizedBox(height: 20),

              // Hospital & Delivery Location Details
              _buildHospitalDetailCard(request),
              const SizedBox(height: 24),

              // Emergency Actions matching Main-4.png
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/contact'),
                  icon: const Icon(Icons.call_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'Contact Donor (Kasun)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084B8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connecting to 24/7 Coordinator: 011 269 1111'),
                        backgroundColor: AppColors.primaryMain,
                      ),
                    );
                  },
                  icon: const Icon(Icons.support_agent_rounded, size: 20, color: Color(0xFF0C549C)),
                  label: const Text(
                    'Call 24/7 Transfusion Coordinator',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0C549C)),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9F2FA),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context, ref, request.id),
                  icon: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFDC2626)),
                  label: const Text(
                    'Cancel Request',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLiveEtaBanner(BloodRequestModel request) {
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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE TELEMETRY',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              StatusPill(status: request.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Estimated Arrival: ~18 mins',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Transfusion units dispatched for ${request.patientName} (${request.bloodType})',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColdChainCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryTeal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.ac_unit, color: AppColors.secondaryTeal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Cold-Chain Telemetry',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OPTIMAL (2°C - 6°C)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Cooler Core Temp: 3.8°C | Sensor ID: #NBTS-CC-409',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BloodRequestModel request) {
    final events = [
      {'title': 'Request Broadcasted', 'desc': 'AI Neural Engine scanned regional donors', 'done': true},
      {'title': 'Donors Matched & Notified', 'desc': '${request.matchedCount} compatible donors found', 'done': true},
      {'title': 'Donor Confirmed / Bag Tagged', 'desc': 'Blood bag barcoding & safety screening', 'done': true},
      {'title': 'Cold-Chain Dispatch En-Route', 'desc': 'Courier transit to destination hospital', 'done': request.status != 'PENDING'},
      {'title': 'Hospital Handover & Transfusion', 'desc': 'Final verification by hospital blood bank', 'done': request.status == 'COMPLETED'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispatch Stage Timeline',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(events.length, (index) {
            final ev = events[index];
            final isDone = ev['done'] as bool;
            final isLast = index == events.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.primaryNavy : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? AppColors.primaryNavy : AppColors.borderLight,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 38,
                        color: isDone ? AppColors.primaryNavy : AppColors.borderLight,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ev['title'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                            color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          ev['desc'] as String,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHospitalDetailCard(BloodRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital & Contact Details',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          _buildDetailRow(Icons.local_hospital, 'Hospital', request.hospitalName),
          if (request.wardNumber != null)
            _buildDetailRow(Icons.meeting_room, 'Ward / Room', request.wardNumber!),
          _buildDetailRow(Icons.phone, 'Emergency Contact', request.contactPhone),
          _buildDetailRow(Icons.water_drop, 'Units Needed', '${request.unitsNeeded} unit(s)'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryNavy),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel this emergency blood request? Active dispatches will be recalled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Active'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final repo = ref.read(requestRepositoryProvider);
                await repo.cancelRequest(id);
                ref.invalidate(myRequestsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Blood request cancelled.')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Cancel Request', style: TextStyle(color: AppColors.accentCrimson)),
          ),
        ],
      ),
    );
  }
}
