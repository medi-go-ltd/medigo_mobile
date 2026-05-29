import 'package:flutter/material.dart';
import 'package:medigo_mobile/config/app_config.dart';
import 'package:medigo_mobile/models/forgot_password_request.dart';
import 'package:medigo_mobile/models/reset_password_request.dart';
import 'package:medigo_mobile/repositories/auth_repository.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/repositories/mock_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';

enum ForgotPasswordStatus { initial, loading, success, error }

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? _defaultRepository();

  final IAuthRepository _authRepository;

  static IAuthRepository _defaultRepository() {
    if (AppConfig.useMockData) {
      return MockAuthRepository();
    }
    return AuthRepository();
  }

  ForgotPasswordStatus _requestStatus = ForgotPasswordStatus.initial;
  ForgotPasswordStatus _resetStatus = ForgotPasswordStatus.initial;
  String? _errorMessage;
  String? _successMessage;
  String? _submittedEmail;

  ForgotPasswordStatus get requestStatus => _requestStatus;
  ForgotPasswordStatus get resetStatus => _resetStatus;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get submittedEmail => _submittedEmail;

  bool get isRequestLoading => _requestStatus == ForgotPasswordStatus.loading;
  bool get isResetLoading => _resetStatus == ForgotPasswordStatus.loading;
  bool get hasRequestError => _requestStatus == ForgotPasswordStatus.error;
  bool get hasResetError => _resetStatus == ForgotPasswordStatus.error;

  Future<bool> requestPasswordReset({required String email}) async {
    try {
      _requestStatus = ForgotPasswordStatus.loading;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final response = await _authRepository.forgotPassword(
        ForgotPasswordRequest(email: email.trim()),
      );

      _submittedEmail = email.trim();
      _requestStatus = ForgotPasswordStatus.success;
      _successMessage = response.message;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _requestStatus = ForgotPasswordStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _requestStatus = ForgotPasswordStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      _resetStatus = ForgotPasswordStatus.loading;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final response = await _authRepository.resetPassword(
        ResetPasswordRequest(
          email: email.trim(),
          token: token.trim(),
          password: password,
        ),
      );

      _resetStatus = ForgotPasswordStatus.success;
      _successMessage = response.message;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _resetStatus = ForgotPasswordStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _resetStatus = ForgotPasswordStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _requestStatus = ForgotPasswordStatus.initial;
    _resetStatus = ForgotPasswordStatus.initial;
    _errorMessage = null;
    _successMessage = null;
    _submittedEmail = null;
    notifyListeners();
  }
}
