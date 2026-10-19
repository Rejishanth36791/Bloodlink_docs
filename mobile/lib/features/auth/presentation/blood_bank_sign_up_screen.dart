import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import 'auth_provider.dart';

class BloodBankSignUpScreen extends ConsumerStatefulWidget {
  const BloodBankSignUpScreen({super.key});

  @override
  ConsumerState<BloodBankSignUpScreen> createState() => _BloodBankSignUpScreenState();
}

class _BloodBankSignUpScreenState extends ConsumerState<BloodBankSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String _facilityType = 'NATIONAL_CENTER';
  String _district = 'Colombo';
  final double _latitude = 6.9271;
  final double _longitude = 79.8612;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authStateProvider.notifier).registerBank(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          facilityType: _facilityType,
          licenseNumber: _licenseController.text.trim(),
          district: _district,
          city: _cityController.text.trim().isEmpty ? 'Colombo' : _cityController.text.trim(),
          address: _addressController.text.trim(),
          contactPhone: _phoneController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
        );

    if (success && mounted) {
      context.go('/account-status');
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
        title: const Text('Blood Bank Registration'),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryMain.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.primaryMain, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'NBTS Clinical Verification: New blood banks require administrator review before going live.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Facility Name
                Text('Blood Bank / Facility Name', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. National Blood Transfusion Service',
                    prefixIcon: Icon(Icons.local_hospital_rounded, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter facility name' : null,
                ),
                const SizedBox(height: 16),

                // Facility Type Dropdown
                Text('Facility Type', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _facilityType,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'NATIONAL_CENTER', child: Text('National Transfusion Center')),
                    DropdownMenuItem(value: 'BASE_HOSPITAL', child: Text('Base / Teaching Hospital')),
                    DropdownMenuItem(value: 'REGIONAL_CENTER', child: Text('Regional Blood Bank')),
                    DropdownMenuItem(value: 'PRIVATE_HOSPITAL', child: Text('Licensed Private Hospital')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _facilityType = v);
                  },
                ),
                const SizedBox(height: 16),

                // License Number
                Text('MOH / NBTS License Number', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. MOH-LK-BB-0419',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'License number is required' : null,
                ),
                const SizedBox(height: 16),

                // Official Email
                Text('Clinical Email', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'bloodbank@nbts.health.gov.lk',
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                ),
                const SizedBox(height: 16),

                // Phone
                Text('Hotline / Phone Number', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+94 11 269 1111',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.length < 9) ? 'Please enter a valid phone number' : null,
                ),
                const SizedBox(height: 16),

                // Password
                Text('Admin Password', style: AppTextStyles.bodySm),
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

                // District & City
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('District', style: AppTextStyles.bodySm),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _district,
                            decoration: const InputDecoration(),
                            items: AppConstants.districts.map((d) {
                              return DropdownMenuItem(value: d, child: Text(d));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _district = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('City', style: AppTextStyles.bodySm),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(hintText: 'e.g. Colombo 05'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Physical Address
                Text('Physical Address', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'No. 555, Elvitigala Mawatha, Narahenpita',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textMuted),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                ),
                const SizedBox(height: 24),

                // Submit button
                CustomButton(
                  text: 'Submit Application for Review',
                  isLoading: isLoading,
                  onPressed: _handleRegister,
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
