import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/booking/patient_booking_flow_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
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

      expect(
        find.text('Who is this appointment for?'),
        findsOneWidget,
      );
      expect(find.text('Myself'), findsOneWidget);
      expect(find.text('Someone else'), findsOneWidget);
    });

    testWidgets('advances to triage step', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Screening questions'), findsOneWidget);
      expect(find.text('Severe chest pain?'), findsOneWidget);
    });
  });
}
