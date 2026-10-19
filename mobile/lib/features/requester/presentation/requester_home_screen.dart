import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/storage/token_storage.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'package:bloodlink_mobile/core/widgets/state_views.dart';
import 'package:bloodlink_mobile/core/widgets/status_pill.dart';
import '../data/request_models.dart';
import 'request_provider.dart';

class RequesterHomeScreen extends ConsumerStatefulWidget {
  const RequesterHomeScreen({super.key});

  @override
  ConsumerState<RequesterHomeScreen> createState() => _RequesterHomeScreenState();
}

class _RequesterHomeScreenState extends ConsumerState<RequesterHomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(myRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(myRequestsProvider),
          color: AppColors.primaryNavy,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // SOS Emergency Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildEmergencySosCard(),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildQuickActionsGrid(),
                ),
              ),

              // Active Requests Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Active Blood Requests',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20, color: AppColors.primaryNavy),
                        onPressed: () => ref.refresh(myRequestsProvider),
                      ),
                    ],
                  ),
                ),
              ),

              // Requests List
              requestsAsync.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(message: 'Scanning active requests...'),
                ),
                error: (err, stack) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateView(
                    title: 'Unable to load requests',
                    message: err.toString(),
                    onRetry: () => ref.refresh(myRequestsProvider),
                  ),
                ),
                data: (requests) {
                  if (requests.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.assignment_outlined,
                        title: 'No Active Requests',
                        subtitle:
                            'You currently have no open blood requests. When you create a request, the AI Neural Engine will immediately match and notify nearby donors.',
                        actionLabel: 'Create Urgent Blood Request',
                        onAction: () => context.push('/new-request'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildRequestCard(requests[index]),
                          );
                        },
                        childCount: requests.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentNavIndex = idx);
          if (idx == 1) {
            context.push('/new-request');
          } else if (idx == 2) {
            context.push('/facilities');
          } else if (idx == 3) {
            _showSignOutDialog(context);
          }
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.primaryNavy.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryNavy),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: AppColors.accentCrimson),
            label: 'New Request',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital, color: AppColors.primaryNavy),
            label: 'Blood Banks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryNavy),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services, color: AppColors.primaryNavy, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Care Portal',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Real-Time Blood Dispatch Service',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_in_talk, color: AppColors.accentCrimson),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('National Ambulance: 1990 | NBTS: 011 269 1111'),
                  backgroundColor: AppColors.primaryNavy,
                ),
              );
            },
            tooltip: 'Emergency Call 1990',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySosCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                'EMERGENCY BLOOD REQUEST',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Need Blood Urgently?',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AI Neural Engine scans verified donors within 5 km and notifies hospital blood banks instantaneously.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/new-request'),
              icon: const Icon(Icons.emergency, color: AppColors.accentCrimson),
              label: Text(
                'Request Blood Now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accentCrimson,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accentCrimson,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.add_circle,
            color: AppColors.accentCrimson,
            title: 'New Request',
            onTap: () => context.push('/new-request'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            icon: Icons.local_hospital,
            color: AppColors.primaryNavy,
            title: 'Blood Banks',
            onTap: () => context.push('/facilities'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            icon: Icons.campaign,
            color: AppColors.secondaryTeal,
            title: 'Blood Camps',
            onTap: () => context.push('/camps'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: request.urgency.toUpperCase() == 'CRITICAL'
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
          // Row: Blood Type + Patient + Urgency Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentCrimson.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    request.bloodType,
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
                        StatusPill(status: request.urgency),
                        const Spacer(),
                        StatusPill(status: request.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Patient: ${request.patientName}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${request.hospitalName}${request.wardNumber != null ? ' (Ward ${request.wardNumber})' : ''}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4-Stage Visual Progress Stepper
          _buildStageStepper(request.status),
          const SizedBox(height: 14),

          // Fulfillment progress details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fulfilled: ${request.unitsFulfilled} / ${request.unitsNeeded} units',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${request.matchedCount} AI matches notified',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: View Matched Donors & Live Tracking
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View Donors (${request.matchedCount})',
                  variant: ButtonVariant.secondary,
                  onPressed: () => context.push('/matches/${request.id}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: 'Track Dispatch',
                  icon: Icons.navigation_outlined,
                  variant: ButtonVariant.primary,
                  onPressed: () => context.push('/tracking/${request.id}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageStepper(String status) {
    int activeStep = 0;
    final upper = status.toUpperCase();
    if (upper == 'MATCHED' || upper == 'NOTIFIED') {
      activeStep = 1;
    } else if (upper == 'ACCEPTED' || upper == 'DISPATCHED' || upper == 'IN_TRANSIT') {
      activeStep = 2;
    } else if (upper == 'FULFILLED' || upper == 'COMPLETED') {
      activeStep = 3;
    }

    final steps = ['Requested', 'AI Match', 'Confirmed', 'Delivered'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          final isCompleted = stepBefore < activeStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primaryNavy : AppColors.borderLight,
            ),
          );
        }

        final stepIdx = index ~/ 2;
        final isCurrent = stepIdx == activeStep;
        final isDone = stepIdx < activeStep;

        return Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primaryNavy
                    : (isCurrent ? AppColors.accentCrimson : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isCurrent ? Colors.transparent : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isCurrent
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIdx],
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
                color: isCurrent
                    ? AppColors.accentCrimson
                    : (isDone ? AppColors.primaryNavy : AppColors.textSecondary),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account Sign Out'),
        content: const Text('Do you want to log out of the Patient Care Portal?'),
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
