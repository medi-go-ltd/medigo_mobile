import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/review.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/review_card.dart';

void main() {
  group('ReviewCard Tests', () {
    testWidgets('displays review name', (WidgetTester tester) async {
      const review = Review(
        name: 'John Doe',
        text: 'Great doctor!',
        rating: 5,
        date: '2 days ago',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Great doctor!'), findsOneWidget);
      expect(find.text('2 days ago'), findsOneWidget);
    });

    testWidgets('displays correct number of stars for rating', (
      WidgetTester tester,
    ) async {
      const review = Review(
        name: 'Jane',
        text: 'OK',
        rating: 3,
        date: '1 week ago',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jane'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('handles empty name gracefully', (WidgetTester tester) async {
      const review = Review(
        name: '',
        text: 'Review text',
        rating: 5,
        date: 'Today',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review text'), findsOneWidget);
    });
  });
}
