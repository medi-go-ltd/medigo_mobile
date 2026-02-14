import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('displays icon, title and subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'No items',
              subtitle: 'Items will appear here.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Items will appear here.'), findsOneWidget);
    });

    testWidgets('displays without subtitle when null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.folder_open,
              title: 'Empty folder',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empty folder'), findsOneWidget);
    });

    testWidgets('uses container style when useContainerStyle is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.history,
              title: 'No history',
              useContainerStyle: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No history'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
