import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/auth/login_screen.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget(Widget home) {
    return AppProviders.wrapWithProviders(
      child: MaterialApp(
        theme: AppTheme.light,
        home: home,
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('displays login form for doctor', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue as Doctor'), findsOneWidget);
      expect(find.text('Email'), findsNWidgets(2));
      expect(find.text('Password'), findsNWidgets(2));
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('displays login form for patient', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.patient)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue as Patient'), findsOneWidget);
      expect(find.text('Email'), findsNWidgets(2));
      expect(find.text('Password'), findsNWidgets(2));
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('displays back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      final passwordFields = find.byType(TextField);
      final passwordField = tester.widgetList<TextField>(passwordFields).last;
      expect(passwordField.obscureText, isTrue);

      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      await tester.tap(visibilityButton);
      await tester.pump();

      final updatedPasswordField = tester
          .widgetList<TextField>(passwordFields)
          .last;
      expect(updatedPasswordField.obscureText, isFalse);
    });

    testWidgets('displays sign up link', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('displays remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remember me'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('toggles remember me checkbox when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);

      await tester.tap(checkbox);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, isTrue);

      await tester.tap(checkbox);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    });

    testWidgets('toggles remember me checkbox when text is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(const LoginScreen(role: UserRole.doctor)),
      );
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);

      await tester.tap(find.text('Remember me'));
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, isTrue);

      await tester.tap(find.text('Remember me'));
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    });
  });
}
