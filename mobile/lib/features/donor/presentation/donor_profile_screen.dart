import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodlink_mobile/core/storage/token_storage.dart';
import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';
import 'package:bloodlink_mobile/core/widgets/custom_button.dart';
import 'donor_provider.dart';

class DonorProfileScreen extends ConsumerWidget {
  const DonorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(donorAvailabilityProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Donor Profile & Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          _buildProfileHeader(context),
          const SizedBox(height: 20),

          // Availability Status Card
          _buildAvailabilityCard(context, ref, isAvailable),
          const SizedBox(height: 20),

          // Quick Navigation Links
          _buildSectionHeader('Donation Records & AI'),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Donation History & Certificates',
            subtitle: 'View your verified units and life-saving timeline',
            onTap: () => context.push('/donation-history'),
          ),
          _buildMenuItem(
            icon: Icons.psychology,
            title: 'NBTS AI Pre-Screening',
            subtitle: 'Check eligibility readiness and recovery timeline',
            onTap: () => context.push('/ai-eligibility'),
          ),
          _buildMenuItem(
            icon: Icons.local_hospital,
            title: 'Nearby Blood Banks & Centers',
            subtitle: 'National Blood Center, Kandy, Karapitiya stations',
            onTap: () => context.push('/facilities'),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('Emergency & Legal'),
          _buildMenuItem(
            icon: Icons.phone_in_talk,
            title: 'National Hotlines',
            subtitle: '1990 Suwa Seriya | NBTS 011 269 1111',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call 1990 for emergency ambulance dispatch.')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy & NBTS Terms',
            subtitle: 'Data governance and donor anonymity protocols',
            onTap: () => context.push('/terms'),
          ),

          const SizedBox(height: 28),
          CustomButton(
            text: 'Sign Out of Account',
            icon: Icons.logout,
            variant: ButtonVariant.dangerOutline,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Sign Out'),
                  content: const Text('Are you sure you want to log out of BloodLink AI?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out', style: TextStyle(color: AppColors.accentCrimson)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final storage = TokenStorage();
                await storage.clearAll();
                if (context.mounted) {
                  context.go('/sign-in');
                }
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryNavy, AppColors.secondaryTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Verified Donor',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: AppColors.primaryNavy, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'NBTS Registered Donor Profile',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentCrimson.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Active Life Saver',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentCrimson,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(BuildContext context, WidgetRef ref, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.successGreen.withValues(alpha: 0.08)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable
              ? AppColors.successGreen.withValues(alpha: 0.4)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.notifications_active : Icons.notifications_off,
            color: isAvailable ? AppColors.successGreen : AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Ready for Emergency Dispatch' : 'Currently Resting / Off Duty',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? AppColors.successGreen : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isAvailable
                      ? 'You will receive real-time alerts when matched.'
                      : 'Hospitals cannot send you emergency requests.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            activeTrackColor: AppColors.successGreen,
            onChanged: (val) {
              ref.read(donorAvailabilityProvider.notifier).toggle(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryNavy, size: 20),
          ),
          title: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}
