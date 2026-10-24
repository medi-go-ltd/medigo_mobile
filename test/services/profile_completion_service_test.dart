import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/user.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/models/verification_status.dart';
import 'package:medigo_mobile/services/profile_completion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

User _patient({String? phone, String? gender}) {
  return User(
    id: 'p1',
    email: 'p@example.com',
    firstName: 'Pat',
    lastName: 'Ent',
    phoneNumber: phone,
    gender: gender,
    role: UserRole.patient,
    verificationStatus: VerificationStatus.approved,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ProfileCompletionService.clearForTests();
  });

  test('just signed up suppresses prompt for current session', () async {
    final user = _patient();
    await ProfileCompletionService.markJustSignedUp();

    expect(await ProfileCompletionService.shouldShowPrompt(user), isFalse);
    // Flag consumed; next check can show if still incomplete.
    expect(await ProfileCompletionService.shouldShowPrompt(user), isTrue);
  });

  test('dismiss hides prompt for cooldown', () async {
    final user = _patient();
    await ProfileCompletionService.dismissPrompt();
    expect(await ProfileCompletionService.shouldShowPrompt(user), isFalse);
  });

  test('complete core fields stops prompt', () async {
    final user = _patient(phone: '+441234', gender: 'Female');
    await ProfileCompletionService.saveDateOfBirth('1990-01-01');
    expect(await ProfileCompletionService.shouldShowPrompt(user), isFalse);
  });
}
