import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import 'auth_provider.dart';

class RequesterSignUpScreen extends ConsumerStatefulWidget {
  const RequesterSignUpScreen({super.key});

  @override
  ConsumerState<RequesterSignUpScreen> createState() => _RequesterSignUpScreenState();
}

class _RequesterSignUpScreenState extends ConsumerState<RequesterSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _staffIdController = TextEditingController();

  String _requesterType = 'PATIENT_FAMILY';
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _hospitalController.dispose();
    _staffIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Privacy Policy to continue'),
          backgroundColor: AppColors.criticalRed,
        ),
      );
      return;
    }

    final success = await ref.read(authStateProvider.notifier).registerRequester(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          requesterType: _requesterType,
          hospitalName: _hospitalController.text.trim().isNotEmpty ? _hospitalController.text.trim() : null,
          staffId: _staffIdController.text.trim().isNotEmpty ? _staffIdController.text.trim() : null,
        );

    if (success && mounted) {
      context.push('/verify-otp', extra: _phoneController.text.trim());
    } else if (mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.criticalRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.canvasTint,
      appBar: AppBar(
        title: const Text('Requester Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Request Blood Urgently',
                  style: AppTextStyles.titleMd,
                ),
                const SizedBox(height: 4),
                Text(
                  'Post verified requests directly to nearby compatible donors and hospital hubs.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Requester Type Selection Cards
                Text('I am registering as:', style: AppTextStyles.titleSm),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildTypeCard('PATIENT_FAMILY', 'Patient / Family', Icons.family_restroom_rounded),
                    const SizedBox(width: 10),
                    _buildTypeCard('HOSPITAL_STAFF', 'Hospital Staff', Icons.local_hospital_rounded),
                  ],
                ),
                const SizedBox(height: 20),

                // Full Name
                Text('Full Name', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Sunil Jayawardena',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                Text('Email Address', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                ),
                const SizedBox(height: 16),

                // Phone
                Text('Emergency Mobile Number (+94)', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+94 77 345 6789',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.length < 9) ? 'Please enter a valid phone number' : null,
                ),
                const SizedBox(height: 16),

                // Password
                Text('Password', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Conditional Hospital fields
                if (_requesterType == 'HOSPITAL_STAFF') ...[
                  Text('Hospital / Clinical Facility', style: AppTextStyles.bodySm),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _hospitalController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. National Hospital of Sri Lanka (NHSL)',
                      prefixIcon: Icon(Icons.business_rounded, color: AppColors.textMuted),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Hospital name is required for staff' : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Staff / Medical ID Number', style: AppTextStyles.bodySm),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _staffIdController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. SLMC-89214',
                      prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      activeColor: AppColors.primaryMain,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/terms'),
                        child: Text(
                          'I agree to NBTS Sri Lanka verification rules & terms.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textBody),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit button
                CustomButton(
                  text: 'Create Requester Account',
                  isLoading: isLoading,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, String title, IconData icon) {
    final isSelected = _requesterType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _requesterType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryMain : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: isSelected ? AppColors.primaryMain : AppColors.textMuted),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
