import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get defaultBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://localhost:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  static String get defaultWsUrl {
    const fromEnv = String.fromEnvironment('WS_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'ws://localhost:8080/ws';
    }
    return 'ws://10.0.2.2:8080/ws';
  }

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String registerDonor = '/api/auth/register/donor';
  static const String registerRequester = '/api/auth/register/requester';
  static const String registerBank = '/api/auth/register/bank';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String verifyPhone = '/api/auth/verify-phone';

  // Me & Profile endpoints
  static const String getProfile = '/api/me';
  static const String updateAvailability = '/api/donors/me/availability';
  static const String updateLocation = '/api/donors/me/location';
  static const String getNotifications = '/api/me/notifications';

  // Blood Request endpoints
  static const String requests = '/api/requests';
  static const String myRequests = '/api/requests/mine';
  static const String nearbyAppeals = '/api/appeals/nearby';
  static const String donorAlerts = '/api/donors/me/alerts';

  // Blood Bank endpoints
  static const String bankDashboard = '/api/bank/dashboard';
  static const String inventoryAdjust = '/api/bank/inventory/adjust';
  static const String nearbyBanks = '/api/banks/nearby';
  static const String camps = '/api/camps';
  static const String nearbyCamps = '/api/camps/nearby';

  // Eligibility
  static const String eligibilityCheck = '/api/donors/me/eligibility';

  // Admin endpoints
  static const String adminPendingBanks = '/api/admin/banks';
  static const String adminAlerts = '/api/admin/alerts';
  static const String adminAnalytics = '/api/admin/analytics';
  static const String adminFlags = '/api/admin/flags';
}
