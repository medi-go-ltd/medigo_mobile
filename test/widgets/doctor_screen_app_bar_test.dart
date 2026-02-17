import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/doctor_screen_app_bar.dart';

void main() {
  group('DoctorScreenAppBar Tests', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            appBar: DoctorScreenAppBar(title: 'Earnings'),
            body: SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Earnings'), findsOneWidget);
    });

    testWidgets('displays settings icon by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            appBar: DoctorScreenAppBar(title: 'History'),
            body: SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('hides settings when showSettings is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            appBar: DoctorScreenAppBar(
              title: 'Reviews',
              showSettings: false,
            ),
            body: SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_outlined), findsNothing);
    });
  });
}
