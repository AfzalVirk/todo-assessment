import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../core/network/dio_client.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      await _persistAuth(response);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      await _persistAuth(response);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      return await _authService.getProfile();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    DioClient.clearToken();
    await StorageService.clearAll();
  }

  Future<void> _persistAuth(AuthResponse response) async {
    await StorageService.saveToken(response.token);
    DioClient.updateToken(response.token);
    if (response.user != null) {
      await StorageService.saveUser(response.user!);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            'An error occurred';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
