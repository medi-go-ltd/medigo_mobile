import 'package:flutter/material.dart';
import 'package:medigo_mobile/config/app_config.dart';
import 'package:medigo_mobile/models/login_request.dart';
import 'package:medigo_mobile/models/social_sign_in_request.dart';
import 'package:medigo_mobile/models/user.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/repositories/auth_repository.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/repositories/mock_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

enum LoginStatus { initial, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final AuthViewModel? _authViewModel;

  LoginViewModel({
    IAuthRepository? authRepository,
    AuthViewModel? authViewModel,
  }) : _authRepository = authRepository ?? _defaultRepository(),
       _authViewModel = authViewModel;

  static IAuthRepository _defaultRepository() {
    if (AppConfig.useMockData) {
      return MockAuthRepository();
    }
    return AuthRepository();
  }

  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;
  User? _user;

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _status == LoginStatus.loading;
  bool get isSuccess => _status == LoginStatus.success;
  bool get hasError => _status == LoginStatus.error;

  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      _status = LoginStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final request = LoginRequest(
        email: email.trim(),
        password: password,
        role: role.name,
      );

      final response = await _authRepository.login(request);

      final token = response.user.token ?? '';
      if (_authViewModel != null && token.isNotEmpty) {
        await _authViewModel.login(response.user, token);
      }

      _user = response.user;
      _status = LoginStatus.success;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on AppException catch (e) {
      _status = LoginStatus.error;
      _errorMessage = e.message;
      _user = null;
      notifyListeners();
      return false;
    } catch (e) {
      _status = LoginStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithSocial(SocialSignInRequest request) async {
    try {
      _status = LoginStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authRepository.signInWithSocial(request);

      final token = response.user.token ?? '';
      if (_authViewModel != null && token.isNotEmpty) {
        await _authViewModel.login(response.user, token);
      }

      _user = response.user;
      _status = LoginStatus.success;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on AppException catch (e) {
      _status = LoginStatus.error;
      _errorMessage = e.message;
      _user = null;
      notifyListeners();
      return false;
    } catch (e) {
      _status = LoginStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _user = null;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = LoginStatus.initial;
    _errorMessage = null;
    _user = null;
    notifyListeners();
  }
}
