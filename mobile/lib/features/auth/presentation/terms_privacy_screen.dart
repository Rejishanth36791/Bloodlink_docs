import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasTint,
      appBar: AppBar(
        title: const Text('Terms & Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NBTS Sri Lanka Regulatory Protocol', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(
                'Last updated: October 2026 • Spec v3.4',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: '1. Medical Guidance Disclaimer',
                body:
                    'BloodLink AI matching algorithms, telemetry, and pre-screen questionnaires provide clinical logistics guidance only. Final donor eligibility and cross-match verification must always be performed by licensed medical officers at verified National Blood Transfusion Service (NBTS) stations.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '2. Privacy & Location Masking',
                body:
                    'To protect donor safety and prevent harassment, exact donor GPS coordinates are strictly masked until a donor voluntarily accepts an urgent request. Once accepted, only transit telemetry and approximate courier distance are shared.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '3. Data Protection Act Compliance',
                body:
                    'All blood group, donation cadence, and hospital requisition data are stored in accordance with Sri Lanka Personal Data Protection Act No. 9 of 2022. No sensitive medical history is sold or shared with commercial entities.',
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '4. Emergency Cold-Chain Integrity',
                body:
                    'Hospital blood banks are solely responsible for ensuring blood component integrity (stored at 2°C to 6°C for whole blood/RBCs and 20°C to 24°C for platelets). Digital ledger movements are immutable.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSm),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textBody)),
        ],
      ),
    );
  }
}
