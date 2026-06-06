import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('AppHeader Tests', () {
    testWidgets('displays logo and app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppHeader()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medi-Go'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays back button by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppHeader()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('hides back button when showBackButton is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppHeader(showBackButton: false)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
      expect(find.text('Medi-Go'), findsOneWidget);
    });

    testWidgets('uses custom onBackPressed callback', (
      WidgetTester tester,
    ) async {
      bool customCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppHeader(
              onBackPressed: () {
                customCallbackCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();

      expect(customCallbackCalled, isTrue);
    });
  });
}
