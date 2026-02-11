import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/auth/signup_screen.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('SignupScreen Tests', () {
    testWidgets('displays registration form for doctor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const SignupScreen(role: UserRole.doctor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create a Doctor account'), findsOneWidget);
      expect(find.text('Medical Registration Number'), findsNWidgets(2));
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('displays registration form for patient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const SignupScreen(role: UserRole.patient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create a Patient account'), findsOneWidget);
      expect(find.text('Confirm Password'), findsNWidgets(2));
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('displays back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const SignupScreen(role: UserRole.doctor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const SignupScreen(role: UserRole.doctor),
        ),
      );
      await tester.pumpAndSettle();

      final passwordFields = find.byType(TextField);
      expect(passwordFields, findsNWidgets(5));

      final passwordField = tester
          .widgetList<TextField>(passwordFields)
          .elementAt(3);
      expect(passwordField.obscureText, isTrue);

      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      await tester.tap(visibilityButton);
      await tester.pump();

      final updatedPasswordField = tester
          .widgetList<TextField>(passwordFields)
          .elementAt(2);
      expect(updatedPasswordField.obscureText, isFalse);
    });

    testWidgets('displays login link', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const SignupScreen(role: UserRole.doctor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log In'), findsOneWidget);
    });
  });
}
