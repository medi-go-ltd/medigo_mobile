import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/user.dart';
import 'package:medigo_mobile/services/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        _token = await StorageService.getToken();
        _user = await StorageService.getUser();
        _isAuthenticated = _token != null && _user != null;
      } else {
        _isAuthenticated = false;
        _user = null;
        _token = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(User user, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.saveToken(token);
      await StorageService.saveUser(user);
      await StorageService.setLoggedIn(true);

      _user = user.copyWith(token: token);
      _token = token;
      _isAuthenticated = true;

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.clearAuthData();

      _user = null;
      _token = null;
      _isAuthenticated = false;

      notifyListeners();
    } catch (e) {
      _user = null;
      _token = null;
      _isAuthenticated = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await StorageService.saveUser(updatedUser);
      _user = updatedUser.copyWith(token: _token);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  bool get isLoggedIn => _isAuthenticated && _user != null && _token != null;
}
