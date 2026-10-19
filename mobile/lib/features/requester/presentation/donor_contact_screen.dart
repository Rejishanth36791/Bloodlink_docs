import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DonorContactScreen extends StatelessWidget {
  final String donorName;
  final String bloodType;
  final String phone;
  final String hospital;
  final String patientName;
  final String ward;

  const DonorContactScreen({
    super.key,
    this.donorName = 'Kasun Mendis',
    this.bloodType = 'O+',
    this.phone = '+94 71 456 7890',
    this.hospital = 'NHSL Colombo',
    this.patientName = 'Sunil Jayawardena',
    this.ward = 'ICU 4B',
  });

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
          'Donor Contact',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confidential Calling Protocol'),
                  content: const Text(
                    'All voice lines are routed through encrypted NBTS relays to maintain clinical donor privacy while providing direct coordinator contact.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Donor Profile Card
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
                    // Avatar with verified badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: Color(0xFF0C549C),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      donorName,
                      style: AppTextStyles.headlineLg.copyWith(fontSize: 22),
                    ),

                    const SizedBox(height: 6),

                    // Badge: VERIFIED O+ DONOR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'VERIFIED $bloodType DONOR',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFF15803D),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sri Lanka Red Cross Volunteer • 14 Successful Donations',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Active Match Mission Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF5FD),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryMain,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ACTIVE MATCH MISSION',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primaryMain,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Emergency $bloodType Whole Blood',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textHeadline,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$patientName • $hospital ($ward)',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textBody,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Status row
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                              Text(
                                'Accepted 8m ago',
                                style: AppTextStyles.caption.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              const Icon(Icons.near_me_outlined, size: 14, color: AppColors.primaryMain),
                              const SizedBox(width: 4),
                              Text(
                                '1.4 km away',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Direct Hospital Transit Line Tag
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0E6F8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sensors_rounded, size: 13, color: AppColors.primaryMain),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Direct Hospital Transit Line',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryMain,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Phone number large
                          Center(
                            child: Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF042954),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Center(
                            child: Text(
                              'Available for immediate coordinator dispatch',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary Button: Call Now
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dialing $donorName ($phone)...'),
                              backgroundColor: AppColors.primaryMain,
                            ),
                          );
                        },
                        icon: const Icon(Icons.call_rounded, size: 20, color: Colors.white),
                        label: Text(
                          'Call $donorName Now',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084B8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Secondary Button: Copy Phone Number
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: phone));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number copied to clipboard!'),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF084B8A)),
                        label: const Text(
                          'Copy Phone Number',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF084B8A),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9F2FA),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Emergency Hotline Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE4E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFFE11D48),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No answer?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeadline,
                            ),
                          ),
                          Text(
                            'Call NHSL Blood Bank Hotline',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0EBF7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '+94 11 269\n1111',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C549C),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Confidentiality notice
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Calls via Blood Link AI are encrypted and masked under National Blood Transfusion Service (NBTS) patient-donor confidentiality guidelines.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        height: 1.35,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
