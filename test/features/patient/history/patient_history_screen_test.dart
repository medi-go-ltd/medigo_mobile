import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/patient/history/patient_history_screen.dart';
import 'package:medigo_mobile/features/patient/history/patient_visit_history_detail_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:provider/provider.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  testWidgets('tapping a visit opens visit detail screen', (tester) async {
    final booking = PatientBooking(
      id: 'hist-2',
      doctor: Doctor(
        id: 'doc-004',
        firstName: 'David',
        lastName: 'Kim',
        specialty: 'Orthopedics',
        fee: 120,
        rating: 4.8,
        reviewCount: 200,
        location: Location(latitude: 51.44, longitude: 0.31),
        estimatedTime: 10,
      ),
      status: PatientBookingStatus.completed,
      amount: 120,
      createdAt: DateTime(2025, 4, 10),
    );

    await initLoggedInPatient();

    await tester.pumpWidget(
      wrapWithProviders(const PatientHistoryScreen()),
    );
    final context = tester.element(find.byType(PatientHistoryScreen));
    context.read<PatientBookingViewModel>().seedCompletedBooking(booking);
    await tester.pumpAndSettle();

    expect(find.text('Dr. David Kim'), findsOneWidget);

    await tester.tap(find.text('Dr. David Kim'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientVisitHistoryDetailScreen), findsOneWidget);
    expect(find.text('Visit Details'), findsOneWidget);
  });
}
