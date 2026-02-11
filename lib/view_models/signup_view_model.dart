import 'package:flutter/material.dart';
import 'package:medigo_mobile/config/app_config.dart';
import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/repositories/auth_repository.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/repositories/mock_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

enum SignupStatus { initial, loading, success, error }

class SignupViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final AuthViewModel? _authViewModel;

  SignupViewModel({
    IAuthRepository? authRepository,
    AuthViewModel? authViewModel,
  })  : _authRepository = authRepository ?? _defaultRepository(),
        _authViewModel = authViewModel;

  static IAuthRepository _defaultRepository() {
    if (AppConfig.useMockData) {
      return MockAuthRepository();
    }
    return AuthRepository();
  }

  SignupStatus _status = SignupStatus.initial;
  String? _errorMessage;

  SignupStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SignupStatus.loading;
  bool get hasError => _status == SignupStatus.error;

  Future<bool> registerDoctor(DoctorRegistrationRequest request) async {
    try {
      _status = SignupStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authRepository.registerDoctor(request);

      final token = response.user.token ?? '';
      if (_authViewModel != null && token.isNotEmpty) {
        await _authViewModel.login(response.user, token);
      }

      _status = SignupStatus.success;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on AppException catch (e) {
      _status = SignupStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = SignupStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = SignupStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
