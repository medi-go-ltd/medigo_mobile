import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_patient_chat_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('DoctorPatientChatScreen Tests', () {
    testWidgets('displays patient name in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorPatientChatScreen(
            patientName: 'Sarah Mitchell',
            appointmentId: 'b-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sarah Mitchell'), findsOneWidget);
      expect(find.text('Secure chat'), findsOneWidget);
    });

    testWidgets('displays message input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorPatientChatScreen(
            patientName: 'Test',
            appointmentId: 'b-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays existing messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorPatientChatScreen(
            patientName: 'Test',
            appointmentId: 'b-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi! I\'m on my way for your consultation.'), findsOneWidget);
      expect(find.text('Thanks, see you soon.'), findsOneWidget);
    });

    testWidgets('displays send button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const DoctorPatientChatScreen(
            patientName: 'Test',
            appointmentId: 'b-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
