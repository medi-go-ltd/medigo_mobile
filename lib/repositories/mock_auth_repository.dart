import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/models/forgot_password_request.dart';
import 'package:medigo_mobile/models/login_request.dart';
import 'package:medigo_mobile/models/login_response.dart';
import 'package:medigo_mobile/models/message_response.dart';
import 'package:medigo_mobile/models/patient_registration_request.dart';
import 'package:medigo_mobile/models/resend_email_verification_request.dart';
import 'package:medigo_mobile/models/reset_password_request.dart';
import 'package:medigo_mobile/models/social_sign_in_request.dart';
import 'package:medigo_mobile/models/verify_email_request.dart';
import 'package:medigo_mobile/repositories/i_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';

class MockAuthRepository implements IAuthRepository {
  static const Duration _delay = Duration(milliseconds: 1500);
  static const String mockVerificationCode = '123456';

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
        'emailVerified': true,
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
        'verificationStatus': 'approved',
        'emailVerified': false,
        'profileImageUrl': null,
        'token': 'mock-jwt-patient-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'message': 'Registration successful. Please verify your email.',
      'success': true,
    });
  }

  @override
  Future<LoginResponse> signInWithSocial(SocialSignInRequest request) async {
    await Future.delayed(_delay);

    if (request.role != 'patient') {
      throw const AuthException('Social sign-in is only available for patients');
    }

    final providerLabel =
        request.provider == SocialProvider.google ? 'Google' : 'Apple';

    return LoginResponse.fromJson({
      'user': {
        'id': 'patient-${request.provider.name}-${DateTime.now().millisecondsSinceEpoch}',
        'email': request.email ??
            'patient.${request.provider.name}@example.com',
        'firstName': request.firstName ?? providerLabel,
        'lastName': request.lastName ?? 'Patient',
        'phoneNumber': null,
        'role': 'patient',
        'gender': null,
        'verificationStatus': 'approved',
        'emailVerified': true,
        'profileImageUrl': null,
        'token':
            'mock-jwt-${request.provider.name}-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'message': 'Signed in with $providerLabel',
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
      userData['emailVerified'] = userData['emailVerified'] ?? true;

      return LoginResponse.fromJson(jsonData);
    } catch (e) {
      return LoginResponse.fromJson({
        'user': {
          'id': 'mock-user-123',
          'email': request.email,
          'firstName': 'John',
          'lastName': 'Doe',
          'role': request.role,
          'emailVerified': true,
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

  @override
  Future<LoginResponse> verifyEmail(VerifyEmailRequest request) async {
    await Future.delayed(_delay);

    if (request.code != mockVerificationCode) {
      throw const AuthException('Invalid or expired verification code');
    }

    return LoginResponse.fromJson({
      'user': {
        'id': 'patient-verified-${DateTime.now().millisecondsSinceEpoch}',
        'email': request.email,
        'firstName': 'Verified',
        'lastName': 'Patient',
        'phoneNumber': null,
        'role': 'patient',
        'gender': null,
        'verificationStatus': 'approved',
        'emailVerified': true,
        'profileImageUrl': null,
        'token':
            'mock-jwt-verified-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      'message': 'Email verified successfully',
      'success': true,
    });
  }

  @override
  Future<MessageResponse> resendEmailVerification(
    ResendEmailVerificationRequest request,
  ) async {
    await Future.delayed(_delay);

    if (request.email.isEmpty) {
      throw const ValidationException('Email is required');
    }

    return const MessageResponse(
      success: true,
      message:
          'If an account exists for this email, a new verification code has been sent.',
    );
  }

  String? _validateMockPassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
