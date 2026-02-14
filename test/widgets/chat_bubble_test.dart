import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/chat_bubble.dart';

void main() {
  group('ChatBubble Tests', () {
    testWidgets('displays message text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ChatBubble(
              text: 'Hello, world!',
              isFromDoctor: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello, world!'), findsOneWidget);
    });

    testWidgets('displays doctor message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ChatBubble(
              text: 'Test',
              isFromDoctor: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(ChatBubble), findsOneWidget);
    });

    testWidgets('displays patient message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ChatBubble(
              text: 'Thanks!',
              isFromDoctor: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thanks!'), findsOneWidget);
    });
  });
}
