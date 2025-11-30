import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/widgets/app_back_button.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('AppBackButton Tests', () {
    testWidgets('displays back icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppBackButton()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('uses default tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppBackButton()),
        ),
      );
      await tester.pumpAndSettle();

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Back');
    });

    testWidgets('uses custom tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AppBackButton(tooltip: 'Go back')),
        ),
      );
      await tester.pumpAndSettle();

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Go back');
    });

    testWidgets('calls Navigator.pop when no custom onPressed provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Column(
                      children: [
                        const AppBackButton(),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const Scaffold(body: AppBackButton()),
                            ),
                          ),
                          child: const Text('Push'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Push'), findsOneWidget);
    });

    testWidgets('calls custom onPressed when provided', (
      WidgetTester tester,
    ) async {
      bool customCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppBackButton(
              onPressed: () {
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
