import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'auth_provider.dart';

class BloodBankSignInScreen extends ConsumerStatefulWidget {
  const BloodBankSignInScreen({super.key});

  @override
  ConsumerState<BloodBankSignInScreen> createState() => _BloodBankSignInScreenState();
}

class _BloodBankSignInScreenState extends ConsumerState<BloodBankSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _keepAuthenticated = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authStateProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      final role = ref.read(authStateProvider).role;
      final status = ref.read(authStateProvider).accountStatus;
      if (status == 'PENDING' || status == 'REJECTED') {
        context.go('/account-status');
      } else if (role == 'BLOOD_BANK' || role == 'ADMIN') {
        context.go('/bank');
      } else {
        context.go('/donor');
      }
    } else if (mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'Institutional login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.criticalRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).status == AuthStatus.loading;

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
          'Institutional Access',
          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Top Banner Card: Blood Bank & Hospital Portal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C549C),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C549C).withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Blood Bank & Hospital Portal',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF38BDF8)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'OFFICIAL NBTS VERIFIED INSTITUTION ACCESS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Subtitle badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secure Institutional Terminal Node (v2.4)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Main Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 14,
                        offset: const Offset(0, 4),
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
                            'Registered Institutional Email',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                          ),
                          Text(
                            'Gov / Health ID',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'e.g. lab@colombo-general.health.gov.lk',
                          hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 13),
                          prefixIcon: const Icon(Icons.apartment_rounded, color: AppColors.textMuted, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid institutional email' : null,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeadline),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter institutional access key',
                          hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Please enter your institutional password' : null,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _keepAuthenticated,
                              activeColor: AppColors.primaryMain,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _keepAuthenticated = val ?? true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keep terminal authenticated',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textBody, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: Text(
                              'Forgot password?',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryMain,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _handleSignIn,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.login_rounded, size: 20, color: Colors.white),
                          label: Text(
                            isLoading ? 'Authenticating...' : 'Sign In to Blood Bank Portal',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C549C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Register Facility Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF5FD),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0E6F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_business_rounded,
                          color: AppColors.primaryMain,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'New Facility or Regional Bank?',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeadline,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Join the Sri Lankan National Transfusion network for dynamic inventory distribution.',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textBody, height: 1.3),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => context.push('/blood-bank-sign-up'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Register your institution',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryMain,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryMain),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Statutory compliance notice
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF0F766E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Authorized healthcare personnel only. Access is cryptographically logged and audited under National Blood Transfusion Service (NBTS) Sri Lanka statutory guidelines.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
