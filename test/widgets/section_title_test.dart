import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/section_title.dart';

void main() {
  group('SectionTitle Tests', () {
    testWidgets('displays title text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SectionTitle(title: 'Personal Details'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal Details'), findsOneWidget);
    });

    testWidgets('displays different titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SectionTitle(title: 'Fees'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fees'), findsOneWidget);
    });
  });
}
