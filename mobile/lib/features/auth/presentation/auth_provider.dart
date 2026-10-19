import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloodlink_mobile/core/storage/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return AuthRepository(storage: storage);
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? role;
  final String? accountStatus;
  final String? userId;
  final String? fullName;
  final String? errorMessage;
  final UserProfileModel? profile;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.accountStatus,
    this.userId,
    this.fullName,
    this.errorMessage,
    this.profile,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? role,
    String? accountStatus,
    String? userId,
    String? fullName,
    String? errorMessage,
    UserProfileModel? profile,
  }) {
    return AuthState(
      status: status ?? this.status,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      errorMessage: errorMessage,
      profile: profile ?? this.profile,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final TokenStorage _storage;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(tokenStorageProvider);
    Future.microtask(() => checkInitialAuth());
    return const AuthState();
  }

  Future<void> checkInitialAuth() async {
    final hasToken = await _storage.hasValidToken();
    if (!hasToken) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final role = await _storage.getUserRole();
      final status = await _storage.getAccountStatus();
      final userId = await _storage.getUserId();
      final name = await _storage.getFullName();

      final profile = await _repository.getProfile();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: role,
        accountStatus: status,
        userId: userId,
        fullName: name,
        profile: profile,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final auth = await _repository.login(identifier: identifier, password: password);
      final profile = await _repository.getProfile();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: auth.role,
        accountStatus: auth.status,
        userId: auth.userId,
        fullName: auth.fullName,
        profile: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> registerDonor({
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
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final auth = await _repository.registerDonor(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
        bloodType: bloodType,
        district: district,
        city: city,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: auth.role,
        accountStatus: auth.status,
        userId: auth.userId,
        fullName: auth.fullName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> registerRequester({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String requesterType,
    String? hospitalName,
    String? staffId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final auth = await _repository.registerRequester(
        email: email,
        phone: phone,
        password: password,
        fullName: fullName,
        requesterType: requesterType,
        hospitalName: hospitalName,
        staffId: staffId,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: auth.role,
        accountStatus: auth.status,
        userId: auth.userId,
        fullName: auth.fullName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> registerBank({
    required String email,
    required String phone,
    required String password,
    required String name,
    required String facilityType,
    required String licenseNumber,
    required String district,
    required String city,
    required String address,
    required String contactPhone,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final auth = await _repository.registerBank(
        email: email,
        phone: phone,
        password: password,
        name: name,
        facilityType: facilityType,
        licenseNumber: licenseNumber,
        district: district,
        city: city,
        address: address,
        contactPhone: contactPhone,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: auth.role,
        accountStatus: auth.status,
        userId: auth.userId,
        fullName: auth.fullName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authStateProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
