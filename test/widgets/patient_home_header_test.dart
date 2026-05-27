import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/profile/patient_profile_screen.dart';
import 'package:medigo_mobile/widgets/patient_home_header.dart';
import '../helpers/test_helpers.dart';

void main() {
  testWidgets('account menu opens profile and shows log out', (tester) async {
    await initLoggedInPatient();

    await tester.pumpWidget(
      wrapWithProviders(
        const Scaffold(body: PatientHomeHeader()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientProfileScreen), findsOneWidget);
  });
}
