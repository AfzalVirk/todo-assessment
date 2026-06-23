import 'user_model.dart';

class AuthResponse {
  final String token;
  final UserModel? user;

  const AuthResponse({required this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return AuthResponse(
      token: data['token']?.toString() ?? '',
      user: UserModel.fromJson(data),
    );
  }
}
