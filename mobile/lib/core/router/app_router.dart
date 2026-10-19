import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bloodlink_mobile/features/auth/presentation/account_status_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/blood_bank_sign_up_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/donor_sign_up_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/onboarding_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/otp_verification_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/requester_sign_up_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/terms_privacy_screen.dart';

import 'package:bloodlink_mobile/features/donor/presentation/ai_eligibility_screen.dart';
import 'package:bloodlink_mobile/features/donor/presentation/donation_history_screen.dart';
import 'package:bloodlink_mobile/features/donor/presentation/donor_alerts_screen.dart';
import 'package:bloodlink_mobile/features/donor/presentation/donor_home_screen.dart';
import 'package:bloodlink_mobile/features/donor/presentation/donor_profile_screen.dart';
import 'package:bloodlink_mobile/features/donor/presentation/urgent_appeals_screen.dart';

import 'package:bloodlink_mobile/features/requester/presentation/matched_donors_screen.dart';
import 'package:bloodlink_mobile/features/requester/presentation/new_request_screen.dart';
import 'package:bloodlink_mobile/features/requester/presentation/request_tracking_screen.dart';
import 'package:bloodlink_mobile/features/requester/presentation/requester_home_screen.dart';

import 'package:bloodlink_mobile/features/auth/presentation/splash_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/blood_bank_sign_in_screen.dart';
import 'package:bloodlink_mobile/features/auth/presentation/admin_login_screen.dart';
import 'package:bloodlink_mobile/features/requester/presentation/donor_contact_screen.dart';
import 'package:bloodlink_mobile/features/bank/presentation/blood_bank_dashboard_screen.dart';
import 'package:bloodlink_mobile/features/bank/presentation/donation_camps_screen.dart';
import 'package:bloodlink_mobile/features/bank/presentation/incoming_donors_screen.dart';
import 'package:bloodlink_mobile/features/bank/presentation/inventory_management_screen.dart';
import 'package:bloodlink_mobile/features/bank/presentation/nearby_facilities_screen.dart';

import 'package:bloodlink_mobile/features/admin/presentation/admin_portal_screen.dart';

import 'package:bloodlink_mobile/core/theme/app_colors.dart';
import 'package:bloodlink_mobile/core/theme/app_text_styles.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.canvasTint,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.route_outlined, size: 64, color: AppColors.primaryMain),
              const SizedBox(height: 16),
              Text('Page Not Found', style: AppTextStyles.headlineLg),
              const SizedBox(height: 8),
              Text(
                'Requested path: ${state.uri}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/sign-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Go to Sign In'),
              ),
            ],
          ),
        ),
      ),
    ),
    routes: [
      // Splash / Root Launch Screen matching 1. Splash/Launch.png
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/bank-sign-in',
        builder: (context, state) => const BloodBankSignInScreen(),
      ),
      GoRoute(
        path: '/bank/login',
        builder: (context, state) => const BloodBankSignInScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/donor-sign-up',
        builder: (context, state) => const DonorSignUpScreen(),
      ),
      GoRoute(
        path: '/signup/donor',
        builder: (context, state) => const DonorSignUpScreen(),
      ),
      GoRoute(
        path: '/requester-sign-up',
        builder: (context, state) => const RequesterSignUpScreen(),
      ),
      GoRoute(
        path: '/signup/requester',
        builder: (context, state) => const RequesterSignUpScreen(),
      ),
      GoRoute(
        path: '/blood-bank-sign-up',
        builder: (context, state) => const BloodBankSignUpScreen(),
      ),
      GoRoute(
        path: '/signup/bank',
        builder: (context, state) => const BloodBankSignUpScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ??
              state.uri.queryParameters['phoneNumber'] ??
              '+94 77 123 4567';
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/account-status',
        builder: (context, state) => const AccountStatusScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/forgotpassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsPrivacyScreen(),
      ),

      // Donor routes
      GoRoute(
        path: '/donor-home',
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/donor',
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/appeals',
        builder: (context, state) => const UrgentAppealsScreen(),
      ),
      GoRoute(
        path: '/donor/appeals',
        builder: (context, state) => const UrgentAppealsScreen(),
      ),
      GoRoute(
        path: '/donation-history',
        builder: (context, state) => const DonationHistoryScreen(),
      ),
      GoRoute(
        path: '/donor/history',
        builder: (context, state) => const DonationHistoryScreen(),
      ),
      GoRoute(
        path: '/donor-profile',
        builder: (context, state) => const DonorProfileScreen(),
      ),
      GoRoute(
        path: '/donor/profile',
        builder: (context, state) => const DonorProfileScreen(),
      ),
      GoRoute(
        path: '/donor-alerts',
        builder: (context, state) => const DonorAlertsScreen(),
      ),
      GoRoute(
        path: '/donor/alerts',
        builder: (context, state) => const DonorAlertsScreen(),
      ),
      GoRoute(
        path: '/ai-eligibility',
        builder: (context, state) => const AiEligibilityScreen(),
      ),
      GoRoute(
        path: '/donor/eligibility',
        builder: (context, state) => const AiEligibilityScreen(),
      ),

      // Requester routes
      GoRoute(
        path: '/requester-home',
        builder: (context, state) => const RequesterHomeScreen(),
      ),
      GoRoute(
        path: '/requester',
        builder: (context, state) => const RequesterHomeScreen(),
      ),
      GoRoute(
        path: '/new-request',
        builder: (context, state) => const NewRequestScreen(),
      ),
      GoRoute(
        path: '/matches/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MatchedDonorsScreen(requestId: id);
        },
      ),
      GoRoute(
        path: '/tracking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RequestTrackingScreen(requestId: id);
        },
      ),

      // Blood bank routes
      GoRoute(
        path: '/bank-dashboard',
        builder: (context, state) => const BloodBankDashboardScreen(),
      ),
      GoRoute(
        path: '/bank',
        builder: (context, state) => const BloodBankDashboardScreen(),
      ),
      GoRoute(
        path: '/bank-inventory',
        builder: (context, state) => const InventoryManagementScreen(),
      ),
      GoRoute(
        path: '/bank-incoming-donors',
        builder: (context, state) => const IncomingDonorsScreen(),
      ),
      GoRoute(
        path: '/camps',
        builder: (context, state) => const DonationCampsScreen(),
      ),
      GoRoute(
        path: '/facilities',
        builder: (context, state) => const NearbyFacilitiesScreen(),
      ),

      // Contact route matching 5. Contact.png
      GoRoute(
        path: '/contact',
        builder: (context, state) => const DonorContactScreen(),
      ),
      GoRoute(
        path: '/contact/:id',
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? 'Kasun Mendis';
          final blood = state.uri.queryParameters['blood'] ?? 'O+';
          final phone = state.uri.queryParameters['phone'] ?? '+94 71 456 7890';
          return DonorContactScreen(
            donorName: name,
            bloodType: blood,
            phone: phone,
          );
        },
      ),

      // Admin portal
      GoRoute(
        path: '/admin-portal',
        builder: (context, state) => const AdminPortalScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPortalScreen(),
      ),
    ],
  );
});
