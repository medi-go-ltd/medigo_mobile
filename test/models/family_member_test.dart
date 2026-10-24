import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/family_member.dart';

void main() {
  FamilyMember member({
    required DateTime dob,
    String? allergies,
    String? medications,
  }) => FamilyMember(
    id: 'fm-1',
    firstName: 'Leo',
    lastName: 'Smith',
    dateOfBirth: dob,
    sexAtBirth: 'Male',
    relationship: FamilyRelationship.child,
    allergies: allergies,
    medications: medications,
  );

  group('FamilyMember', () {
    test('ageOn accounts for whether the birthday has passed', () {
      final m = member(dob: DateTime(2010, 6, 15));
      expect(m.ageOn(DateTime(2026, 6, 14)), 15);
      expect(m.ageOn(DateTime(2026, 6, 15)), 16);
    });

    test('isMinor is true under 16', () {
      final now = DateTime.now();
      expect(member(dob: DateTime(now.year - 4, 1, 1)).isMinor, isTrue);
      expect(member(dob: DateTime(now.year - 30, 1, 1)).isMinor, isFalse);
    });

    test('ageLabel uses months under two years', () {
      final now = DateTime.now();
      final baby = member(dob: DateTime(now.year, now.month - 5, 1));
      expect(baby.ageLabel, '5 months');
      expect(member(dob: DateTime(now.year - 4, 1, 1)).ageLabel, '4 yrs');
    });

    test('healthNotes joins only the non-empty fields', () {
      expect(member(dob: DateTime(2020)).healthNotes, isNull);
      expect(
        member(
          dob: DateTime(2020),
          allergies: ' Peanuts ',
          medications: 'Inhaler',
        ).healthNotes,
        'Allergies: Peanuts; Medications: Inhaler',
      );
    });

    test('round-trips through JSON', () {
      final original = member(dob: DateTime(2020, 3, 4), allergies: 'Dust');
      final copy = FamilyMember.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.fullName, 'Leo Smith');
      expect(copy.dateOfBirth, original.dateOfBirth);
      expect(copy.relationship, FamilyRelationship.child);
      expect(copy.sexAtBirth, 'Male');
      expect(copy.allergies, 'Dust');
    });
  });
}
