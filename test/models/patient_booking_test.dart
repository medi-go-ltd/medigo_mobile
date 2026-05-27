import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
void main() {
  group('TriageAnswers', () {
    test('isUrgent when any symptom is yes', () {
      const urgent = TriageAnswers(severeChestPain: true);
      const notUrgent = TriageAnswers();

      expect(urgent.isUrgent, isTrue);
      expect(notUrgent.isUrgent, isFalse);
    });

    test('copyWith updates single field', () {
      const original = TriageAnswers();
      final updated = original.copyWith(difficultyBreathing: true);

      expect(updated.difficultyBreathing, isTrue);
      expect(updated.severeChestPain, isFalse);
    });
  });

  group('PatientBooking', () {
    test('paymentMethodLabel returns readable label', () {
      final booking = PatientBooking(
        id: '1',
        doctor: Doctor(
          id: 'd1',
          firstName: 'A',
          lastName: 'B',
          specialty: 'GP',
          fee: 100,
          profileImageUrl: '',
          rating: 5,
          reviewCount: 1,
          location: Location(latitude: 0, longitude: 0),
          estimatedTime: 10,
        ),
        paymentMethod: PaymentMethodType.applePay,
        amount: 100,
        createdAt: DateTime(2025),
      );

      expect(booking.paymentMethodLabel, 'Apple Pay');
      expect(booking.statusLabel, 'Draft');
    });
  });
}
