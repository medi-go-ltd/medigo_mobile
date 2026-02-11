import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/welcome/welcome_screen.dart';
import 'package:medigo_mobile/features/auth/login_screen.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
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
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: home,
      ),
    );
  }

  group('WelcomeScreen Tests', () {
    testWidgets('displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const WelcomeScreen()));
      await tester.pump();

      expect(find.text('Medi Go'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign in as Doctor'), findsOneWidget);
      expect(find.text('Sign in as Patient'), findsOneWidget);
    });

    testWidgets('displays app logo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const WelcomeScreen()));
      await tester.pump();

      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('navigates to login screen when doctor button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const WelcomeScreen()));
      await tester.pump();

      final doctorButton = find.text('Sign in as Doctor');
      expect(doctorButton, findsOneWidget);

      await tester.tap(doctorButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('navigates to login screen when patient button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const WelcomeScreen()));
      await tester.pump();

      final patientButton = find.text('Sign in as Patient');
      expect(patientButton, findsOneWidget);

      await tester.tap(patientButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('highlights button when selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const WelcomeScreen()));
      await tester.pump();

      final doctorButton = find.text('Sign in as Doctor');
      await tester.tap(doctorButton);
      await tester.pump();

      final containers = find.byType(AnimatedContainer);
      expect(containers, findsWidgets);

      final activeContainer = tester
          .widgetList<AnimatedContainer>(containers)
          .firstWhere((container) {
            final decoration = container.decoration as BoxDecoration?;
            return decoration?.color == AppColors.highlight;
          });

      expect(activeContainer, isNotNull);
    });
  });
}
