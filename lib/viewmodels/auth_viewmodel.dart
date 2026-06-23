import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/storage_service.dart';
import '../core/network/dio_client.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  UserModel? _user;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _loadPersistedUser();
  }

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoading => _state == AuthState.loading;
  bool get isLoggedIn => StorageService.isLoggedIn;

  void _loadPersistedUser() {
    _user = StorageService.getUser();
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      DioClient.updateToken(token);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      final response = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      if (response.user != null) {
        _user = response.user;
      }
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _user = response.user;
      }
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<void> fetchProfile() async {
    _setState(AuthState.loading);
    try {
      _user = await _repository.getProfile();
      await StorageService.saveUser(_user!);
      _setState(AuthState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _errorMessage = null;
    _setState(AuthState.idle);
  }

  void clearError() {
    _errorMessage = null;
    _setState(AuthState.idle);
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
