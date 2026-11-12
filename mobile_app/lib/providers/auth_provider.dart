import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  bool get isLawyer => _currentUser?.isLawyer ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService().init();
      if (ApiService().token != null && ApiService().token!.isNotEmpty) {
        _currentUser = await ApiService().getMe();
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Check auth error: $e');
      await ApiService().clearToken();
      _currentUser = null;
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> login(String emailOrPhone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().login(emailOrPhone, password);
      _currentUser = UserModel.fromJson(res['user']);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().register(userData);
      _currentUser = UserModel.fromJson(res['user']);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      _currentUser = await ApiService().getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await ApiService().clearToken();
    _currentUser = null;
    notifyListeners();
  }
}

