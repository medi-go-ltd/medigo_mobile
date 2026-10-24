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

abstract class IAuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> registerDoctor(DoctorRegistrationRequest request);
  Future<LoginResponse> registerPatient(PatientRegistrationRequest request);
  Future<LoginResponse> signInWithSocial(SocialSignInRequest request);
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request);
  Future<MessageResponse> resetPassword(ResetPasswordRequest request);
  Future<LoginResponse> verifyEmail(VerifyEmailRequest request);
  Future<MessageResponse> resendEmailVerification(
    ResendEmailVerificationRequest request,
  );
}
