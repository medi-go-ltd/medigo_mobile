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
              isOutgoing: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello, world!'), findsOneWidget);
    });

    testWidgets('outgoing messages align right', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ChatBubble(
              text: 'My message',
              isOutgoing: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('incoming messages align left', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ChatBubble(
              text: 'Their message',
              isOutgoing: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });
  });
}
