import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/role_segment_controller.dart';
import 'auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedRoleIndex = 0; // 0 = Donor, 1 = Requester
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authStateProvider.notifier).login(
          _identifierController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      final role = ref.read(authStateProvider).role;
      if (role == 'DONOR') {
        context.go('/donor');
      } else if (role == 'REQUESTER') {
        context.go('/requester');
      } else if (role == 'BLOOD_BANK') {
        final status = ref.read(authStateProvider).accountStatus;
        if (status == 'PENDING' || status == 'REJECTED') {
          context.go('/account-status');
        } else {
          context.go('/bank');
        }
      } else if (role == 'ADMIN') {
        context.go('/admin');
      }
    } else if (mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'Login failed';
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
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.canvasTint,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Welcome back',
                    style: AppTextStyles.headlineLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to access your donation hub',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Role Segment Controller
                  RoleSegmentController(
                    selectedIndex: _selectedRoleIndex,
                    firstLabel: 'Donor',
                    secondLabel: 'Requester',
                    firstIcon: Icons.favorite_rounded,
                    secondIcon: Icons.volunteer_activism_rounded,
                    onRoleChanged: (idx) => setState(() => _selectedRoleIndex = idx),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Toggling affects your sign-up destination',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Mobile / Email input
                  Text('Mobile Number or Email', style: AppTextStyles.bodySm),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _identifierController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. +94 77 123 4567 or name@mail.com',
                      prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.textMuted),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email or mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  Text('Password', style: AppTextStyles.bodySm),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Remember me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              activeColor: AppColors.primaryMain,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Remember me', style: AppTextStyles.bodySm),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  CustomButton(
                    text: 'Sign In',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isLoading,
                    onPressed: _handleSignIn,
                  ),
                  const SizedBox(height: 20),

                  // Create Account Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New here? ', style: AppTextStyles.bodyMd),
                      GestureDetector(
                        onTap: () {
                          if (_selectedRoleIndex == 0) {
                            context.push('/donor-sign-up');
                          } else {
                            context.push('/requester-sign-up');
                          }
                        },
                        child: Text(
                          'Create an account',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedRoleIndex == 0 ? 'Routes to Donor Sign Up' : 'Routes to Requester Sign Up',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Healthcare Professional / Blood Bank Banner matching 5. Sign In (Shared).png
                  InkWell(
                    onTap: () => context.push('/bank-sign-in'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryMain.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: AppColors.primaryMain,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Healthcare professional?',
                                  style: AppTextStyles.titleSm.copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hospital & Blood Bank access',
                                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppColors.primaryMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push('/admin-login'),
                      icon: const Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                      label: Text(
                        'System Administrator Console',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
