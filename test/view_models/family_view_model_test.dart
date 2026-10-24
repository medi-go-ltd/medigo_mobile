import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/family_member.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/view_models/family_view_model.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final child = FamilyMember(
    id: 'fm-1',
    firstName: 'Leo',
    lastName: 'Smith',
    dateOfBirth: DateTime(2022, 1, 1),
    sexAtBirth: 'Male',
    relationship: FamilyRelationship.child,
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('FamilyViewModel', () {
    test('persists members per account', () async {
      final vm = FamilyViewModel();
      await vm.loadFor('user-a');
      await vm.add(child);

      final reloaded = FamilyViewModel();
      await reloaded.loadFor('user-a');
      expect(reloaded.members.map((m) => m.id), ['fm-1']);

      final otherAccount = FamilyViewModel();
      await otherAccount.loadFor('user-b');
      expect(otherAccount.members, isEmpty);
    });

    test('adding while still loading keeps the saved members', () async {
      SharedPreferences.setMockInitialValues({
        'family_members_user-a':
            '[{"id":"fm-0","firstName":"Ann","lastName":"Smith",'
            '"dateOfBirth":"1960-01-01T00:00:00.000","sexAtBirth":"Female",'
            '"relationship":"parent"}]',
      });
      final vm = FamilyViewModel();
      unawaited(vm.loadFor('user-a'));
      await vm.add(child);

      expect(vm.members.map((m) => m.id), ['fm-0', 'fm-1']);
      final reloaded = FamilyViewModel();
      await reloaded.loadFor('user-a');
      expect(reloaded.members.map((m) => m.id), ['fm-0', 'fm-1']);
    });

    test('update and remove', () async {
      final vm = FamilyViewModel();
      await vm.loadFor('user-a');
      await vm.add(child);

      await vm.update(
        FamilyMember.fromJson({...child.toJson(), 'firstName': 'Leon'}),
      );
      expect(vm.byId('fm-1')?.firstName, 'Leon');

      await vm.remove('fm-1');
      expect(vm.members, isEmpty);
    });
  });

  group('PatientBookingViewModel family draft', () {
    final doctor = Doctor(
      id: 'doc-1',
      firstName: 'Jane',
      lastName: 'Doe',
      specialty: 'GP',
      fee: 100,
      profileImageUrl: '',
      rating: 5,
      reviewCount: 1,
      location: Location(latitude: 51.5, longitude: 0.1, address: 'London'),
      estimatedTime: 10,
    );

    test('setPatients reprices: full fee then 50% per extra person', () {
      final vm = PatientBookingViewModel()..startBooking(doctor);
      expect(vm.draft!.amount, 100);

      vm.setPatients([null, child]);
      expect(vm.draft!.patients.map((p) => p.key), ['self', 'fm-1']);
      expect(vm.draft!.amount, 150);
      expect(vm.draft!.appointmentForLabel, startsWith('Myself, Leo Smith'));

      vm.setPatients([child]);
      expect(vm.draft!.amount, 100);
      expect(vm.draft!.appointmentForLabel, startsWith('Leo Smith (Child'));
    });

    test('answers stay with each person when the selection changes', () {
      final vm = PatientBookingViewModel()..startBooking(doctor);
      vm.setPatients([null, child]);
      vm.updatePatient(1, bodyAreas: ['Chest'], description: 'Cough');
      vm.updatePatient(0, triage: const TriageAnswers(severePain: true));

      vm.setPatients([child]);
      expect(vm.draft!.patients.single.bodyAreas, ['Chest']);
      expect(vm.draft!.patients.single.description, 'Cough');
      expect(vm.draft!.isUrgent, isFalse);
    });
  });

  test('totalFee', () {
    expect(PatientBooking.totalFee(120, 1), 120);
    expect(PatientBooking.totalFee(120, 3), 240);
  });
}
