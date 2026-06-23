import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  static Future<void> saveToken(String token) async {
    await _instance.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _instance.getString(AppConstants.tokenKey);
  }

  static Future<void> saveUser(UserModel user) async {
    await _instance.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final userJson = _instance.getString(AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    await _instance.remove(AppConstants.tokenKey);
    await _instance.remove(AppConstants.userKey);
  }
}
