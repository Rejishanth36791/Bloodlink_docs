import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/blood_type_selector.dart';
import '../../../core/widgets/custom_button.dart';
import 'auth_provider.dart';

class DonorSignUpScreen extends ConsumerStatefulWidget {
  const DonorSignUpScreen({super.key});

  @override
  ConsumerState<DonorSignUpScreen> createState() => _DonorSignUpScreenState();
}

class _DonorSignUpScreenState extends ConsumerState<DonorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedBloodType = 'O+';
  String _selectedDistrict = 'Colombo';
  double _latitude = 6.9271; // Default Colombo coordinates
  double _longitude = 79.8612;
  bool _isLocating = false;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS coordinates captured successfully'),
              backgroundColor: AppColors.lifeGreen,
            ),
          );
        }
      }
    } catch (_) {
      // Fallback to Colombo defaults
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
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

    final success = await ref.read(authStateProvider.notifier).registerDonor(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          bloodType: _selectedBloodType,
          district: _selectedDistrict,
          city: _cityController.text.trim().isEmpty ? 'Colombo' : _cityController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
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
        title: const Text('Donor Registration'),
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
                  'Join Verified Sri Lankan Donors',
                  style: AppTextStyles.titleMd,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile connects with patients within minutes during emergency alerts.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Full Name
                Text('Full Name (as in NIC/Passport)', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Kasun Mendis',
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
                Text('Mobile Number (+94)', style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+94 77 123 4567',
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
                const SizedBox(height: 20),

                // Blood Type Matrix
                Text('Your Blood Group', style: AppTextStyles.titleSm),
                const SizedBox(height: 8),
                BloodTypeSelector(
                  selectedType: _selectedBloodType,
                  onSelected: (t) => setState(() => _selectedBloodType = t),
                ),
                const SizedBox(height: 20),

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
                            initialValue: _selectedDistrict,
                            decoration: const InputDecoration(),
                            items: AppConstants.districts.map((d) {
                              return DropdownMenuItem(value: d, child: Text(d));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedDistrict = val);
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
                          Text('City / Town', style: AppTextStyles.bodySm),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(hintText: 'e.g. Maharagama'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // GPS Location Capture
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryMain.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.primaryMain, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'GPS Coordinates: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLocating ? null : _detectLocation,
                        child: _isLocating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Update'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
                          'I agree to NBTS Sri Lanka medical donation policies and terms.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textBody),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit button
                CustomButton(
                  text: 'Create Donor Profile',
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
}
