import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/auth/patient_signup_screen.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildWidget() {
    return AppProviders.wrapWithProviders(
      child: MaterialApp(
        theme: AppTheme.light,
        home: const PatientSignupScreen(),
      ),
    );
  }

  group('PatientSignupScreen', () {
    testWidgets('shows short signup form without document uploads', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create patient account'), findsOneWidget);
      expect(find.textContaining('First Name'), findsWidgets);
      expect(find.textContaining('Last Name'), findsWidgets);
      expect(find.textContaining('Email'), findsWidgets);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.textContaining('Profile Picture'), findsNothing);
      expect(find.textContaining('proof of address'), findsNothing);
      expect(find.text('Medical'), findsNothing);
      expect(find.text('Preferences'), findsNothing);
    });
  });
}
