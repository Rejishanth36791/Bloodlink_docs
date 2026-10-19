import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController(text: '+94 77 982 3411');
  final _newPasswordController = TextEditingController(text: 'AyubowanBlood2024!');
  final _confirmPasswordController = TextEditingController(text: 'AyubowanBlood2024!');
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(text: ['4', '8', '2', '9', '1', '6'][index]),
  );

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleResetPassword() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully! Please sign in with your new credentials.'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        context.go('/sign-in');
      }
    });
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
          'Account Recovery',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Circular Recovery Icon with badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE0F2FE),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 38,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
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
                'Trouble signing in?',
                style: AppTextStyles.headlineLg.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                'Enter your verified Sri Lankan mobile number (+94) or email. We will send a secure 6-digit recovery code.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textBody,
                  height: 1.35,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Step 1: Recovery Contact
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Step 1 • Recovery Contact',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '✔ Verified Line',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_iphone_rounded, color: AppColors.textHeadline, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _phoneController.text,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHeadline),
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF5FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.primaryMain),
                          const SizedBox(width: 6),
                          Text(
                            'Code Sent • Resend in 24s',
                            style: AppTextStyles.caption.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Step 2: 6-Digit SMS Code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Step 2 • 6-Digit SMS Code',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                        ),
                        Text(
                          '✉ SMS via Mobitel',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 44,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF5FD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: index == 5 ? AppColors.primaryMain : const Color(0xFFCBD5E1),
                              width: index == 5 ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: index == 5
                                ? Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0C549C),
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : Text(
                                    _otpControllers[index].text,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF042954),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Entering the final digit validates your session instantly',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Step 3: New Password
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 3 • New Password',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.key_rounded, color: AppColors.textHeadline, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _obscurePassword ? '••••••••••••••••' : _newPasswordController.text,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHeadline),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Entropy & Complexity', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                        Row(
                          children: [
                            const Icon(Icons.shield_rounded, size: 12, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              'Strong',
                              style: AppTextStyles.caption.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Confirm New Password',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHeadline),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, color: AppColors.textHeadline, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _obscurePassword ? '••••••••••••••••' : _confirmPasswordController.text,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textHeadline),
                            ),
                          ),
                          const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // AI Guard Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.smart_toy_outlined, color: AppColors.primaryMain, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BloodLink AI Guard',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Emergency response donors & hospital coordinators receive cryptographic token renewal upon password update.',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textBody, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Updating...' : 'Reset Password',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084B8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton.icon(
                onPressed: () => context.go('/sign-in'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textHeadline),
                label: const Text(
                  'Return to Login',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHeadline),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
