import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 1: Every Drop Counts (Why Donate)
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Text(
                      'NATIONAL BLOOD CARE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHeadline,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/sign-in'),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Skip', style: TextStyle(color: AppColors.textHeadline, fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hero Banner Illustration
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_rounded,
                            size: 48,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sri Lanka NBTS Clinical Network',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Row(
                    children: [
                      _buildDot(0),
                      _buildDot(1),
                      _buildDot(2),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(
                          'COMMUNITY IMPACT',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Headline
          const Text(
            'Every drop counts.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Just one blood donation can save up to 3 lives across Sri Lanka. Join thousands of hero donors ready to respond in minutes.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textBody,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // 2 Stats Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Color(0xFF1D4ED8), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '3 Lives',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textHeadline),
                            ),
                            Text(
                              'Per donation unit',
                              style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.timer_outlined, color: Color(0xFF15803D), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '< 15 mins',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textHeadline),
                            ),
                            Text(
                              'Average procedure',
                              style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // National Stock Demand card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'National Stock Demand',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Live Need',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sri Lanka needs over 400,000 units annually. Your donation keeps emergency stocks alive.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textBody, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              label: const Text('Next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF084B8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Text(
                  'Endorsed by National Blood Transfusion Service',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Page 2: AI finds the right donor, fast
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => context.go('/sign-in'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Skip', style: TextStyle(color: AppColors.textHeadline, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 12),

          // Hero Banner Illustration
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            size: 48,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sri Lanka Neural Dispatch Engine',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Row(
                    children: [
                      _buildDot(0),
                      _buildDot(1),
                      _buildDot(2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tag Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, size: 10, color: Color(0xFF0284C7)),
                const SizedBox(width: 4),
                Text(
                  'REAL-TIME RADAR',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF0284C7),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(color: Color(0xFF0284C7), shape: BoxShape.circle),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'AI finds the right donor, fast.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Our intelligent dispatch algorithms match urgent hospital requests with nearby compatible donors in real-time, reducing transit delays to zero.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textBody,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Dispatch Telemetry Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.alt_route_rounded, color: Color(0xFF0284C7), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dispatch Telemetry',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '99.4% Precision',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Algorithmic routing considers traffic, blood shelf-life, and past donation intervals for maximum recipient safety.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textBody, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              label: const Text('Next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF084B8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Page 3: Together, we save lives
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'National Network Live',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Hero Banner Illustration
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            size: 48,
                            color: Color(0xFF0C549C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Doctors, Donors & NBTS Sri Lanka',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Row(
                    children: [
                      _buildDot(0),
                      _buildDot(1),
                      _buildDot(2),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFF0284C7)),
                        const SizedBox(width: 4),
                        Text(
                          'CONNECTED HEALTHCARE',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF0284C7),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Together, we save lives.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Bridging donors, emergency requesters, certified blood banks, and verified hospital staff into one trusted national network.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textBody,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Unified Ecosystem Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_outline_rounded, color: Color(0xFF0C549C), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unified Ecosystem',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textHeadline),
                      ),
                      Text(
                        'Connecting 4,200+ healthcare heroes islandwide',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C549C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NBTS SL',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3 Feature Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeaturePill(Icons.check_circle_rounded, '100% Certified Labs'),
              _buildFeaturePill(Icons.shield_rounded, 'NBTS Compliant'),
              _buildFeaturePill(Icons.lock_rounded, 'Encrypted Data'),
            ],
          ),

          const SizedBox(height: 24),

          // Get Started Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/sign-in'),
              label: const Text('Get Started', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF084B8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Already registered with NBTS? ',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                InkWell(
                  onTap: () => context.go('/sign-in'),
                  child: Text(
                    'Sign In',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryMain,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isCurrent = _currentPage == index;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: isCurrent ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF0C549C) : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF16A34A)),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
