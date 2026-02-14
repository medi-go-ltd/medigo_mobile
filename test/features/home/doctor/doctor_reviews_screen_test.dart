import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_reviews_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('DoctorReviewsScreen Tests', () {
    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorReviewsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reviews'), findsOneWidget);
    });

    testWidgets('displays back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorReviewsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays mock reviews from repository', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorReviewsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sarah Mitchell'), findsOneWidget);
      expect(find.text('John Kelly'), findsOneWidget);
    });

    testWidgets('pops when back button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorReviewsScreen(),
                      ),
                    ),
                    child: const Text('Open Reviews'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Reviews'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorReviewsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorReviewsScreen), findsNothing);
    });
  });
}
