import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'auth_provider.dart';

class AccountStatusScreen extends ConsumerStatefulWidget {
  const AccountStatusScreen({super.key});

  @override
  ConsumerState<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends ConsumerState<AccountStatusScreen> {
  int _selectedTabIndex = 0; // 0 = Under Review, 1 = Not Approved
  bool _isRefreshing = false;

  Future<void> _checkVerificationStatus() async {
    setState(() => _isRefreshing = true);
    await ref.read(authStateProvider.notifier).checkInitialAuth();
    if (mounted) {
      setState(() => _isRefreshing = false);
      final status = ref.read(authStateProvider).accountStatus;
      if (status == 'ACTIVE') {
        final role = ref.read(authStateProvider).role;
        if (role == 'BLOOD_BANK' || role == 'ADMIN') {
          context.go('/bank');
        } else {
          context.go('/donor');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status: $status. NBTS clinical review in progress.'),
            backgroundColor: AppColors.primaryMain,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasTint,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textHeadline),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Verification Status',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryMain),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.primaryMain),
            onPressed: _isRefreshing ? null : _checkVerificationStatus,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Top Segment Controller (Under Review vs Not Approved)
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? const Color(0xFF0C549C) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: _selectedTabIndex == 0 ? Colors.white : const Color(0xFF0C549C),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Under Review',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedTabIndex == 0 ? Colors.white : const Color(0xFF0C549C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? const Color(0xFF0C549C) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                  color: _selectedTabIndex == 1 ? Colors.white : const Color(0xFF0C549C),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Not Approved',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedTabIndex == 1 ? Colors.white : const Color(0xFF0C549C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (_selectedTabIndex == 0) _buildUnderReviewTab() else _buildNotApprovedTab(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderReviewTab() {
    return Column(
      children: [
        // Main Review Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Gold Hourglass with Warm Halo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF3C7),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 36,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Pill: Pending NBTS Clinical Review
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pending NBTS Clinical Review',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your account is under review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Our verification team is validating your healthcare institution license (NBTS-WP-2024-0891) with the Sri Lanka Ministry of Health. This usually takes 2–4 hours during clinical shifts.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textBody,
                  height: 1.4,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Queue Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryMain),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Queue: General Hospital Colombo Node',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHeadline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '~1h 45m left',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryMain,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Verification Sequence Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verification Sequence',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textHeadline),
                  ),
                  Text(
                    'Step 2 of 3',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Step 1: Application Submitted
              _buildTimelineStep(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
                title: 'Application Submitted',
                badgeText: 'Today, 09:14 AM',
                badgeColor: const Color(0xFFF1F5F9),
                badgeTextColor: AppColors.textMuted,
                subtitle: 'Digital identity documents and bio-facility profile encrypted.',
                isLast: false,
              ),

              // Step 2: License Authenticity Check
              _buildTimelineStep(
                icon: Icons.sync_rounded,
                iconColor: const Color(0xFFD97706),
                title: 'License Authenticity Check',
                badgeText: 'In Progress',
                badgeColor: const Color(0xFFFEF3C7),
                badgeTextColor: const Color(0xFFB45309),
                subtitle: 'Cross-referencing medical register WP/24 with National Blood Transfusion Service database.',
                isLast: false,
              ),

              // Step 3: Dispatch Gateway Activation
              _buildTimelineStep(
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.textMuted,
                title: 'Dispatch Gateway Activation',
                badgeText: 'Awaiting clearance',
                badgeColor: const Color(0xFFF1F5F9),
                badgeTextColor: AppColors.textMuted,
                subtitle: 'Issuance of emergency dispatch broadcast access and direct ambulance link.',
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // AI Routing Engine Ready Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF5FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F766E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Routing Engine Ready',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                    ),
                    Text(
                      'Donor proximity cluster: 42 compatible donors ready',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textBody, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryMain),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Emergency Hotline Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF5FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFD0E6F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_rounded, color: AppColors.primaryMain, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need urgent emergency activation?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                    ),
                    Text(
                      'NBTS Colombo HQ (+94 11 269 3444)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryMain),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Disabled Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('Continue to Portal (Disabled until approved)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCBD5E1),
              foregroundColor: const Color(0xFF64748B),
              disabledBackgroundColor: const Color(0xFFDCE7F5),
              disabledForegroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotApprovedTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.cancel_outlined, size: 40, color: Color(0xFFDC2626)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Application Not Approved',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textHeadline),
          ),
          const SizedBox(height: 8),
          Text(
            'The medical director credentials could not be cross-validated against the official Sri Lanka Medical Council registry. Please update your license info or appeal.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textBody, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.push('/blood-bank-sign-up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMain,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Resubmit License Documents', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(color: AppColors.textBody, height: 1.3, fontSize: 11),
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
