import 'package:bloodlink_mobile/core/constants/api_constants.dart';
import 'package:bloodlink_mobile/core/network/api_client.dart';
import 'package:bloodlink_mobile/core/storage/token_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRepository({ApiClient? client, TokenStorage? storage})
      : apiClient = client ?? ApiClient(),
        tokenStorage = storage ?? TokenStorage();

  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.login,
      data: {
        'identifier': identifier,
        'password': password,
      },
    );

    final auth = AuthResponseModel.fromJson(response.data);
    await tokenStorage.saveAuth(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
      role: auth.role,
      status: auth.status,
      fullName: auth.fullName,
      email: auth.email,
      phone: auth.phone,
    );
    return auth;
  }

  Future<AuthResponseModel> registerDonor({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String bloodType,
    required String district,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.registerDonor,
      data: {
        'email': email,
        'phone': phone,
        'password': password,
        'fullName': fullName,
        'bloodType': bloodType,
        'district': district,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final auth = AuthResponseModel.fromJson(response.data);
    await tokenStorage.saveAuth(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
      role: auth.role,
      status: auth.status,
      fullName: auth.fullName,
      email: auth.email,
      phone: auth.phone,
    );
    return auth;
  }

  Future<AuthResponseModel> registerRequester({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String requesterType, // PATIENT_FAMILY, HOSPITAL_STAFF, EMERGENCY_DISPATCHER
    String? hospitalName,
    String? staffId,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.registerRequester,
      data: {
        'email': email,
        'phone': phone,
        'password': password,
        'fullName': fullName,
        'requesterType': requesterType,
        if (hospitalName != null && hospitalName.isNotEmpty) 'hospitalName': hospitalName,
        if (staffId != null && staffId.isNotEmpty) 'staffId': staffId,
      },
    );

    final auth = AuthResponseModel.fromJson(response.data);
    await tokenStorage.saveAuth(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
      role: auth.role,
      status: auth.status,
      fullName: auth.fullName,
      email: auth.email,
      phone: auth.phone,
    );
    return auth;
  }

  Future<AuthResponseModel> registerBank({
    required String email,
    required String phone,
    required String password,
    required String name,
    required String facilityType, // NATIONAL_CENTER, BASE_HOSPITAL, PRIVATE_HOSPITAL, REGIONAL_CENTER
    required String licenseNumber,
    required String district,
    required String city,
    required String address,
    required String contactPhone,
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.registerBank,
      data: {
        'email': email,
        'phone': phone,
        'password': password,
        'name': name,
        'facilityType': facilityType,
        'licenseNumber': licenseNumber,
        'district': district,
        'city': city,
        'address': address,
        'contactPhone': contactPhone,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final auth = AuthResponseModel.fromJson(response.data);
    await tokenStorage.saveAuth(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.userId,
      role: auth.role,
      status: auth.status,
      fullName: auth.fullName,
      email: auth.email,
      phone: auth.phone,
    );
    return auth;
  }

  Future<void> verifyPhone({
    required String otp,
    String? firebaseIdToken,
  }) async {
    await apiClient.dio.post(
      ApiConstants.verifyPhone,
      data: {
        'otp': otp,
        'firebaseIdToken': firebaseIdToken ?? 'simulated_phone_token_$otp',
      },
    );
  }

  Future<UserProfileModel> getProfile() async {
    final response = await apiClient.dio.get(ApiConstants.getProfile);
    return UserProfileModel.fromJson(response.data);
  }

  Future<void> logout() async {
    try {
      final refresh = await tokenStorage.getRefreshToken();
      await apiClient.dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refresh},
      );
    } catch (_) {
      // Ignore network failure on logout
    } finally {
      await tokenStorage.clearAuth();
    }
  }
}
