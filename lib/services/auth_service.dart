import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../services/storage_service.dart'; // add this
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    final authResponse =
        AuthResponse.fromJson(response.data as Map<String, dynamic>);

    // ✅ Save token and user after register
    if (authResponse.token != null) {
      await StorageService.saveToken(authResponse.token!);
    }
    if (authResponse.user != null) {
      await StorageService.saveUser(authResponse.user!);
    }

    return authResponse;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final authResponse =
        AuthResponse.fromJson(response.data as Map<String, dynamic>);

    // ✅ Save token and user after login
    if (authResponse.token != null) {
      await StorageService.saveToken(authResponse.token!);
    }
    if (authResponse.user != null) {
      await StorageService.saveUser(authResponse.user!);
    }

    return authResponse;
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    final data = response.data as Map<String, dynamic>;
    final userData = data['data'] as Map<String, dynamic>? ?? data;
    return UserModel.fromJson(userData);
  }
}
