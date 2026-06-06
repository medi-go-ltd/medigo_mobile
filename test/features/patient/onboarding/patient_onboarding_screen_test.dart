import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/onboarding/patient_onboarding_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PatientOnboardingScreen', () {
    testWidgets('displays legal acceptance checkboxes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const PatientOnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Medi-Go'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Community Standards'), findsOneWidget);
      expect(find.text('Domestic Violence Declaration'), findsOneWidget);
      expect(find.text('Legal / Policy Documents'), findsOneWidget);
    });

    testWidgets('continue disabled until all legal items accepted', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const PatientOnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull);
    });
  });
}
