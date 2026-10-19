import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';
  static const _keyAccountStatus = 'account_status';
  static const _keyFullName = 'full_name';
  static const _keyEmail = 'email';
  static const _keyPhone = 'phone';

  Future<void> saveAuth({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String status,
    required String fullName,
    String? email,
    String? phone,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUserRole, value: role),
      _storage.write(key: _keyAccountStatus, value: status),
      _storage.write(key: _keyFullName, value: fullName),
      if (email != null) _storage.write(key: _keyEmail, value: email),
      if (phone != null) _storage.write(key: _keyPhone, value: phone),
    ]);
  }

  Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(key: _keyAccessToken, value: newAccessToken);
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() async => await _storage.read(key: _keyRefreshToken);
  Future<String?> getUserId() async => await _storage.read(key: _keyUserId);
  Future<String?> getUserRole() async => await _storage.read(key: _keyUserRole);
  Future<String?> getRole() async => await getUserRole();
  Future<String?> getAccountStatus() async => await _storage.read(key: _keyAccountStatus);
  Future<String?> getFullName() async => await _storage.read(key: _keyFullName);
  Future<String?> getEmail() async => await _storage.read(key: _keyEmail);
  Future<String?> getPhone() async => await _storage.read(key: _keyPhone);

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuth() async {
    await _storage.deleteAll();
  }

  Future<void> clearAll() async => await clearAuth();
}
