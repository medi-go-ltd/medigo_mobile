import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/booking/patient_booking_flow_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/family_member.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/family_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final testDoctor = Doctor(
    id: 'doc-1',
    firstName: 'Jane',
    lastName: 'Smith',
    specialty: 'GP',
    fee: 120,
    profileImageUrl: '',
    rating: 4.8,
    reviewCount: 10,
    location: Location(
      latitude: 51.5,
      longitude: 0.1,
      address: 'London',
    ),
    estimatedTime: 15,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildWidget() {
    return AppProviders.wrapWithProviders(
      child: MaterialApp(
        theme: AppTheme.light,
        home: PatientBookingFlowScreen(doctor: testDoctor),
      ),
    );
  }

  group('PatientBookingFlowScreen', () {
    testWidgets('starts on who is appointment for step', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Who needs to be seen?'), findsOneWidget);
      expect(find.text('Myself'), findsOneWidget);
      expect(find.text('Add family member'), findsOneWidget);
    });

    testWidgets('advances to triage step', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Screening questions'), findsOneWidget);
      expect(find.text('Severe chest pain?'), findsOneWidget);
    });

    testWidgets('can select several people and requires adult consent', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final family = tester
          .element(find.byType(PatientBookingFlowScreen))
          .read<FamilyViewModel>();
      await family.loadFor('user-1');
      await family.add(
        FamilyMember(
          id: 'fm-adult',
          firstName: 'Janet',
          lastName: 'Anderson',
          dateOfBirth: DateTime(1990, 1, 1),
          sexAtBirth: 'Female',
          relationship: FamilyRelationship.sibling,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Janet Anderson'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 people on one visit'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please confirm Janet agrees to this booking'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      final consent = find.text('Janet knows about and agrees to this booking');
      await tester.ensureVisible(consent);
      await tester.tap(consent);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Screening questions'), findsOneWidget);
      expect(find.text('Screening your symptoms (1 of 2)'), findsOneWidget);
    });
  });
}
