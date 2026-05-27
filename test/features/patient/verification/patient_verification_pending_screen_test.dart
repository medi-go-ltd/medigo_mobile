import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/verification/patient_verification_pending_screen.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PatientVerificationPendingScreen', () {
    testWidgets('displays verification status items', (tester) async {
      await tester.pumpWidget(
        AppProviders.wrapWithProviders(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PatientVerificationPendingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Created'), findsOneWidget);
      expect(find.text('Email verification'), findsOneWidget);
      expect(find.text('Address verification'), findsOneWidget);
      expect(find.text('Photo ID verification'), findsOneWidget);
      expect(find.text('Continue to Onboarding'), findsOneWidget);
    });
  });
}
