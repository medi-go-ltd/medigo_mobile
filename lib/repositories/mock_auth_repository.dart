import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/models/forgot_password_request.dart';
import 'package:medigo_mobile/models/login_request.dart';
import 'package:medigo_mobile/models/login_response.dart';
import 'package:medigo_mobile/models/message_response.dart';
import 'package:medigo_mobile/models/patient_registration_request.dart';
import 'package:medigo_mobile/models/reset_password_request.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';

class MockAuthRepository implements IAuthRepository {
  static const Duration _delay = Duration(milliseconds: 1500);

  @override
  Future<LoginResponse> registerDoctor(DoctorRegistrationRequest request) async {
    await Future.delayed(_delay);

    return LoginResponse.fromJson({
      'user': {
        'id': 'doctor-new-${DateTime.now().millisecondsSinceEpoch}',
        'email': request.email,
        'firstName': request.firstName,
        'lastName': request.lastName,
        'phoneNumber': request.phoneNumber,
        'role': 'doctor',
        'verificationStatus': 'pending',
        'profileImageUrl': null,
        'token': 'mock-jwt-doctor-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'message': 'Registration successful. Your account is pending verification.',
      'success': true,
    });
  }

  @override
  Future<LoginResponse> registerPatient(
    PatientRegistrationRequest request,
  ) async {
    await Future.delayed(_delay);

    return LoginResponse.fromJson({
      'user': {
        'id': 'patient-new-${DateTime.now().millisecondsSinceEpoch}',
        'email': request.email,
        'firstName': request.firstName,
        'lastName': request.lastName,
        'phoneNumber': request.phoneNumber,
        'role': 'patient',
        'gender': request.gender,
        'verificationStatus': 'pending',
        'profileImageUrl': null,
        'token': 'mock-jwt-patient-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'message':
          'Registration successful. Your account is pending verification.',
      'success': true,
    });
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    await Future.delayed(_delay);

    if (request.email.isEmpty || request.password.isEmpty) {
      throw const ValidationException('Email and password are required');
    }

    if (request.password.length < 6) {
      throw const AuthException('Invalid credentials');
    }

    try {
      final String jsonString = request.role == 'doctor'
          ? await rootBundle.loadString(
              'assets/mock_data/mock_doctor_user.json',
            )
          : await rootBundle.loadString(
              'assets/mock_data/mock_patient_user.json',
            );

      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final userData = jsonData['user'] as Map<String, dynamic>;
      userData['email'] = request.email;
      userData['role'] = request.role;

      return LoginResponse.fromJson(jsonData);
    } catch (e) {
      return LoginResponse.fromJson({
        'user': {
          'id': 'mock-user-123',
          'email': request.email,
          'firstName': 'John',
          'lastName': 'Doe',
          'role': request.role,
          'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
        },
        'message': 'Login successful (mock)',
        'success': true,
      });
    }
  }

  @override
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) async {
    await Future.delayed(_delay);

    if (request.email.isEmpty) {
      throw const ValidationException('Email is required');
    }

    return const MessageResponse(
      success: true,
      message:
          'If an account exists for this email, you will receive password reset instructions shortly.',
    );
  }

  @override
  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    await Future.delayed(_delay);

    if (request.token.isEmpty) {
      throw const ValidationException('Reset code is required');
    }

    if (request.token == 'invalid') {
      throw const AuthException('Invalid or expired reset token');
    }

    final passwordError = _validateMockPassword(request.password);
    if (passwordError != null) {
      throw ValidationException(passwordError);
    }

    return const MessageResponse(
      success: true,
      message:
          'Password updated successfully. You can sign in with your new password.',
    );
  }

  String? _validateMockPassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
