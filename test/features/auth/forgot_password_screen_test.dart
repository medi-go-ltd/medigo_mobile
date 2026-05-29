import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/auth/forgot_password_screen.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget(Widget home) {
    return AppProviders.wrapWithProviders(
      child: MaterialApp(theme: AppTheme.light, home: home),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('displays forgot password form', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ForgotPasswordScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Forgot password'), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);
      expect(find.text('Back to login'), findsOneWidget);
    });

    testWidgets('prefills email when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ForgotPasswordScreen(initialEmail: 'user@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
    });
  });
}
