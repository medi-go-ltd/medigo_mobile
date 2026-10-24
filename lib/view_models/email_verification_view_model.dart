import 'package:flutter/material.dart';
import 'package:medigo_mobile/config/app_config.dart';
import 'package:medigo_mobile/models/resend_email_verification_request.dart';
import 'package:medigo_mobile/models/user.dart';
import 'package:medigo_mobile/models/verify_email_request.dart';
import 'package:medigo_mobile/repositories/auth_repository.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/repositories/mock_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

enum EmailVerificationStatus { initial, loading, success, error }

class EmailVerificationViewModel extends ChangeNotifier {
  EmailVerificationViewModel({
    IAuthRepository? authRepository,
    AuthViewModel? authViewModel,
  }) : _authRepository = authRepository ?? _defaultRepository(),
       _authViewModel = authViewModel;

  final IAuthRepository _authRepository;
  final AuthViewModel? _authViewModel;

  static IAuthRepository _defaultRepository() {
    if (AppConfig.useMockData) {
      return MockAuthRepository();
    }
    return AuthRepository();
  }

  EmailVerificationStatus _verifyStatus = EmailVerificationStatus.initial;
  EmailVerificationStatus _resendStatus = EmailVerificationStatus.initial;
  String? _errorMessage;
  String? _successMessage;
  User? _user;

  EmailVerificationStatus get verifyStatus => _verifyStatus;
  EmailVerificationStatus get resendStatus => _resendStatus;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  User? get user => _user;

  bool get isVerifyLoading =>
      _verifyStatus == EmailVerificationStatus.loading;
  bool get isResendLoading =>
      _resendStatus == EmailVerificationStatus.loading;

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      _verifyStatus = EmailVerificationStatus.loading;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final response = await _authRepository.verifyEmail(
        VerifyEmailRequest(email: email.trim(), code: code.trim()),
      );

      final existing = _authViewModel?.user;
      final verifiedUser = existing != null
          ? response.user.copyWith(
              firstName: existing.firstName.isNotEmpty
                  ? existing.firstName
                  : response.user.firstName,
              lastName: existing.lastName.isNotEmpty
                  ? existing.lastName
                  : response.user.lastName,
              phoneNumber: existing.phoneNumber ?? response.user.phoneNumber,
              gender: existing.gender ?? response.user.gender,
              profileImageUrl:
                  existing.profileImageUrl ?? response.user.profileImageUrl,
            )
          : response.user;

      final token = verifiedUser.token ?? response.user.token ?? '';
      if (_authViewModel != null && token.isNotEmpty) {
        await _authViewModel.login(verifiedUser, token);
      }

      _user = verifiedUser;
      _verifyStatus = EmailVerificationStatus.success;
      _successMessage = response.message;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _verifyStatus = EmailVerificationStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _verifyStatus = EmailVerificationStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendCode({required String email}) async {
    try {
      _resendStatus = EmailVerificationStatus.loading;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final response = await _authRepository.resendEmailVerification(
        ResendEmailVerificationRequest(email: email.trim()),
      );

      _resendStatus = EmailVerificationStatus.success;
      _successMessage = response.message;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _resendStatus = EmailVerificationStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _resendStatus = EmailVerificationStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
