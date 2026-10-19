import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_pill.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/donor_models.dart';
import 'donor_provider.dart';

class DonorHomeScreen extends ConsumerWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAvailable = ref.watch(donorAvailabilityProvider);
    final appealsAsync = ref.watch(nearbyAppealsProvider);

    final fullName = authState.fullName ?? 'Donor';
    final donorProfile = authState.profile?.donorProfile;
    final bloodType = donorProfile?['bloodType']?.toString() ?? 'O+';
    final district = donorProfile?['district']?.toString() ?? 'Colombo';
    final totalDonations = (donorProfile?['totalDonations'] as num?)?.toInt() ?? 0;
    final livesSaved = totalDonations * 3;

    return Scaffold(
      backgroundColor: AppColors.canvasTint,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(nearbyAppealsProvider);
            ref.invalidate(donorAlertsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryMain,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'BloodLink',
                                    style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.aiIntelligence,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                                        const SizedBox(width: 3),
                                        Text(
                                          'AI Powered',
                                          style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text('Donor Home Dashboard', style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Badge(
                          smallSize: 8,
                          backgroundColor: AppColors.criticalRed,
                          child: Icon(Icons.notifications_outlined, size: 26),
                        ),
                        onPressed: () => context.push('/donor/alerts'),
                      ),
                    ],
                  ),
                ),

                // Hero Blue Gradient Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryMain, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: AppTextStyles.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Good morning, $fullName 👋',
                        style: AppTextStyles.headlineLg.copyWith(color: Colors.white, fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 15, color: Colors.white.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            '$district, Western Province',
                            style: AppTextStyles.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Availability Switch Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isAvailable ? AppColors.lifeGreen : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isAvailable ? 'Available to donate' : 'Standby / Paused',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: isAvailable,
                              activeTrackColor: AppColors.lifeGreen,
                              onChanged: (val) {
                                ref.read(donorAvailabilityProvider.notifier).toggle(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlapping Donor Metric Card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primaryMain,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.water_drop_rounded, color: Colors.white, size: 16),
                                Text(
                                  bloodType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      bloodType == 'O-' ? 'Universal Donor' : 'Blood Donor',
                                      style: AppTextStyles.titleSm,
                                    ),
                                    const SizedBox(width: 8),
                                    const StatusPill(label: 'Active', variant: PillVariant.approved),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Whole Blood & Platelets',
                                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lifeGreenLight,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '92%',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.lifeGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.water_drop_outlined, '$totalDonations Donations'),
                          _buildStatItem(Icons.volunteer_activism_outlined, '$livesSaved Lives Saved'),
                          _buildStatItem(Icons.share_location_rounded, district),
                        ],
                      ),
                    ],
                  ),
                ),

                // 4 Quick Action Circles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionCircle(
                        icon: Icons.water_drop_rounded,
                        label: 'Donate',
                        color: AppColors.primaryMain,
                        onTap: () => context.push('/donor/eligibility'),
                      ),
                      _buildActionCircle(
                        icon: Icons.emergency_rounded,
                        label: 'Appeals',
                        color: AppColors.criticalRed,
                        onTap: () => context.push('/donor/appeals'),
                      ),
                      _buildActionCircle(
                        icon: Icons.history_edu_rounded,
                        label: 'History',
                        color: AppColors.aiIntelligence,
                        onTap: () => context.push('/donor/history'),
                      ),
                      _buildActionCircle(
                        icon: Icons.groups_rounded,
                        label: 'Invite',
                        color: AppColors.lifeGreen,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('BloodLink invitation link copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Urgent Appeals Near You Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.criticalRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Urgent Appeals Near You', style: AppTextStyles.titleSm),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/donor/appeals'),
                        child: Text(
                          'See all',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryMain),
                        ),
                      ),
                    ],
                  ),
                ),

                // Appeals List / Loading / Empty State
                appealsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: LoadingView(message: 'Scanning active hospital requests...'),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorStateView(
                      error: err.toString(),
                      onRetry: () => ref.refresh(nearbyAppealsProvider),
                    ),
                  ),
                  data: (appeals) {
                    if (appeals.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: EmptyStateView(
                          title: 'No Active Appeals Right Now',
                          message: 'All regional requirements in your zone are currently fulfilled. Standby for AI emergency alerts.',
                          icon: Icons.volunteer_activism_outlined,
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: appeals.take(3).length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final appeal = appeals[index];
                        return _buildAppealCard(context, appeal);
                      },
                    );
                  },
                ),

                // Western Province Supply Widget
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.primaryMain),
                              const SizedBox(width: 8),
                              Text('Western Province Supply', style: AppTextStyles.titleSm.copyWith(fontSize: 15)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.lifeGreenLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Updated 10m ago',
                              style: AppTextStyles.caption.copyWith(color: AppColors.lifeGreen, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildSupplyPill('O+', 'Normal', AppColors.lifeGreen),
                          const SizedBox(width: 8),
                          _buildSupplyPill('O-', 'Critical', AppColors.criticalRed),
                          const SizedBox(width: 8),
                          _buildSupplyPill('B+', 'Optimal', AppColors.lifeGreen),
                          const SizedBox(width: 8),
                          _buildSupplyPill('AB-', 'Low', AppColors.amberWarning),
                        ],
                      ),
                    ],
                  ),
                ),

                // AI Donor Milestone
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.aiLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.aiIntelligence.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 16, color: AppColors.aiIntelligence),
                              const SizedBox(width: 6),
                              Text(
                                'AI DONOR MILESTONE',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.aiIntelligence,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Tier 2 Donor',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '🔥 3-Donation Annual Streak!',
                        style: AppTextStyles.titleSm,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are 1 donation away from earning the verified Gold LifeSaver Badge.',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textBody),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0.75,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.aiIntelligence),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Next camp: Colombo Town Hall',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.push('/camps'),
                            child: Text(
                              'RSVP →',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.aiIntelligence,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryMain),
        const SizedBox(width: 5),
        Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textBody)),
      ],
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealCard(BuildContext context, AppealModel appeal) {
    final isCritical = appeal.urgency == 'CRITICAL';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? AppColors.criticalRed.withValues(alpha: 0.25) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                label: isCritical ? 'CRITICAL • <20m window' : 'URGENT',
                variant: isCritical ? PillVariant.critical : PillVariant.urgent,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appeal.bloodType,
                  style: AppTextStyles.titleSm.copyWith(
                    color: AppColors.primaryMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${appeal.unitsNeeded} Units Whole Blood',
            style: AppTextStyles.titleSm,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  appeal.hospitalName,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.near_me_outlined, size: 14, color: AppColors.primaryMain),
              const SizedBox(width: 4),
              Text(
                '${appeal.distanceKm?.toStringAsFixed(1) ?? '2.4'} km (${appeal.etaMinutes ?? 15} min)',
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryMain),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: 'Respond to Appeal',
            icon: Icons.volunteer_activism_rounded,
            height: 42,
            onPressed: () => context.push('/donor/appeals'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyPill(String type, String status, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(type, style: AppTextStyles.titleSm.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(status, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    return NavigationBar(
      selectedIndex: activeIndex,
      backgroundColor: AppColors.surfaceWhite,
      elevation: 4,
      onDestinationSelected: (idx) {
        if (idx == 0) return;
        if (idx == 1) context.push('/donor/alerts');
        if (idx == 2) context.push('/donor/eligibility');
        if (idx == 3) context.push('/donor/history');
        if (idx == 4) context.push('/donor/profile');
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        NavigationDestination(icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop_rounded), label: 'Donate'),
        NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history_rounded), label: 'History'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}
