import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/shared/set_radius_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('SetRadiusScreen Tests', () {
    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SetRadiusScreen(
            initialRadius: 15,
            initialIsAvailable: true,
            onSave: (_, _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set Radius'), findsOneWidget);
    });

    testWidgets('displays operating radius label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SetRadiusScreen(
            initialRadius: 15,
            initialIsAvailable: true,
            onSave: (_, _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Operating radius (km)'), findsOneWidget);
    });

    testWidgets('displays initial radius value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SetRadiusScreen(
            initialRadius: 25,
            initialIsAvailable: true,
            onSave: (_, _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('25 km'), findsOneWidget);
    });

    testWidgets('displays checkbox for set available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SetRadiusScreen(
            initialRadius: 15,
            initialIsAvailable: true,
            onSave: (_, _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set status to Available when I save'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('calls onSave when Save button tapped', (
      WidgetTester tester,
    ) async {
      double? savedRadius;
      bool? savedAvailable;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SetRadiusScreen(
            initialRadius: 20,
            initialIsAvailable: false,
            onSave: (radius, available) {
              savedRadius = radius;
              savedAvailable = available;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(savedRadius, 20);
      expect(savedAvailable, isFalse);
    });

    testWidgets('pops when close button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SetRadiusScreen(
                      initialRadius: 15,
                      initialIsAvailable: true,
                      onSave: (_, _) {},
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(SetRadiusScreen), findsNothing);
    });
  });
}
