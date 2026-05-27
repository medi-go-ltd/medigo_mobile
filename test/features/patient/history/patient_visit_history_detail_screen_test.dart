import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/history/patient_visit_history_detail_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

PatientBooking _completedBooking() {
  return PatientBooking(
    id: 'hist-1',
    doctor: Doctor(
      id: 'doc-005',
      firstName: 'James',
      lastName: 'Wilson',
      specialty: 'General Practice',
      fee: 100,
      rating: 4.5,
      reviewCount: 178,
      location: Location(
        latitude: 51.436,
        longitude: 0.34,
        address: 'Fleet Health Campus, Vale Rd, Northfleet',
      ),
      estimatedTime: 6,
    ),
    status: PatientBookingStatus.completed,
    bodyArea: 'Chest',
    description: 'Persistent cough for 3 days',
    paymentMethod: PaymentMethodType.debitCard,
    amount: 100,
    createdAt: DateTime(2025, 5, 20, 14, 30),
    rating: 4,
    review: 'Professional and thorough',
  );
}

void main() {
  testWidgets('shows visit details for completed booking', (tester) async {
    final booking = _completedBooking();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PatientVisitHistoryDetailScreen(booking: booking),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Visit Details'), findsOneWidget);
    expect(find.text('Dr. James Wilson'), findsOneWidget);
    expect(find.text('General Practice'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Persistent cough for 3 days'), findsOneWidget);
    expect(find.text('£100'), findsWidgets);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Professional and thorough'), findsOneWidget);
  });
}
