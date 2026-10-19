import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/otp_input_row.dart';
import 'auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _otpCode = '';
  bool _isVerifying = false;
  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatPhone(String raw) {
    if (raw.length >= 7) {
      final prefix = raw.substring(0, raw.length - 4);
      final suffix = raw.substring(raw.length - 3);
      return '$prefix •••• $suffix';
    }
    return raw;
  }

  Future<void> _handleVerify() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the verification code'),
          backgroundColor: AppColors.criticalRed,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.verifyPhone(otp: _otpCode);

      if (mounted) {
        final role = ref.read(authStateProvider).role;
        if (role == 'DONOR') {
          context.go('/donor');
        } else if (role == 'REQUESTER') {
          context.go('/requester');
        } else {
          context.go('/bank');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.criticalRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasTint,
      appBar: AppBar(
        title: const Text('Phone Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryMain),
                    const SizedBox(width: 6),
                    Text(
                      'Hospital Safe Auth Protocol',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter 6-Digit Code',
                style: AppTextStyles.headlineLg,
              ),
              const SizedBox(height: 8),
              Text(
                'SMS verification code dispatched to ${_formatPhone(widget.phoneNumber)}.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textBody),
              ),
              const SizedBox(height: 32),

              // 6-Box OTP input
              OtpInputRow(
                length: 6,
                onChanged: (code) => _otpCode = code,
                onCompleted: (code) {
                  _otpCode = code;
                  _handleVerify();
                },
              ),
              const SizedBox(height: 24),

              // Resend Timer
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend in 0:${_secondsRemaining.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : TextButton(
                        onPressed: _startTimer,
                        child: Text(
                          'Resend Code via SMS',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const Spacer(),

              // Verify button
              CustomButton(
                text: 'Verify & Continue',
                isLoading: _isVerifying,
                onPressed: _handleVerify,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
