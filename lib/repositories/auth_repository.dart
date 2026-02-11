import 'dart:convert';
import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/models/login_request.dart';
import 'package:medigo_mobile/models/login_response.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/services/api_service.dart';
import 'package:medigo_mobile/utils/app_exception.dart';

class AuthRepository implements IAuthRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<LoginResponse> registerDoctor(DoctorRegistrationRequest request) async {
    try {
      final response = await _apiService.post(
        '/doctors/register',
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          responseData: errorData,
        );
      }
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ApiException(
        'Invalid response format from server',
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post('/login', body: request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          responseData: errorData,
        );
      }
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ApiException(
        'Invalid response format from server',
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException.fromError(e);
    }
  }
}
