import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({Dio? customDio, TokenStorage? customStorage})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.defaultBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ),
        tokenStorage = customStorage ?? TokenStorage() {
    _initInterceptors();
  }

  void _initInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If unauthorized and not already refreshing auth
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/api/auth/')) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await tokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              await tokenStorage.clearAuth();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.defaultBaseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccess = response.data['accessToken'];
        final newRefresh = response.data['refreshToken'];

        if (newAccess != null) {
          await tokenStorage.updateAccessToken(newAccess);
          if (newRefresh != null) {
            final userId = await tokenStorage.getUserId() ?? '';
            final role = await tokenStorage.getUserRole() ?? '';
            final status = await tokenStorage.getAccountStatus() ?? '';
            final fullName = await tokenStorage.getFullName() ?? '';

            await tokenStorage.saveAuth(
              accessToken: newAccess,
              refreshToken: newRefresh,
              userId: userId,
              role: role,
              status: status,
              fullName: fullName,
            );
          }
          return true;
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  // Helper for cleaner exception messages
  static String formatError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        final data = error.response!.data as Map;
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Server connection timed out. Please check your network.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to BloodLink backend (${ApiConstants.defaultBaseUrl}). Ensure the server is running.';
      }
      return error.message ?? 'An unexpected network error occurred.';
    }
    return error.toString();
  }
}
