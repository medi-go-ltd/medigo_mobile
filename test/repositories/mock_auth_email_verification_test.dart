import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/patient_registration_request.dart';
import 'package:medigo_mobile/models/resend_email_verification_request.dart';
import 'package:medigo_mobile/models/verify_email_request.dart';
import 'package:medigo_mobile/repositories/mock_auth_repository.dart';
import 'package:medigo_mobile/utils/app_exception.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  test('email signup returns unverified patient', () async {
    final response = await repo.registerPatient(
      PatientRegistrationRequest(
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        password: 'password123',
      ),
    );

    expect(response.user.emailVerified, isFalse);
    expect(response.user.email, 'jane@example.com');
  });

  test('verify email accepts mock code 123456', () async {
    final response = await repo.verifyEmail(
      const VerifyEmailRequest(
        email: 'jane@example.com',
        code: MockAuthRepository.mockVerificationCode,
      ),
    );

    expect(response.user.emailVerified, isTrue);
    expect(response.success, isTrue);
  });

  test('verify email rejects invalid code', () async {
    expect(
      () => repo.verifyEmail(
        const VerifyEmailRequest(email: 'jane@example.com', code: '000000'),
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('resend email verification succeeds', () async {
    final response = await repo.resendEmailVerification(
      const ResendEmailVerificationRequest(email: 'jane@example.com'),
    );
    expect(response.success, isTrue);
  });
}
