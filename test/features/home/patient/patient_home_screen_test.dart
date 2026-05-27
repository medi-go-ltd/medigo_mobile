import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/patient/patient_home_screen.dart';
import 'package:medigo_mobile/features/patient/appointments/patient_appointments_screen.dart';
import 'package:medigo_mobile/features/patient/history/patient_history_screen.dart';
import 'package:medigo_mobile/features/patient/payments/patient_payments_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('PatientHomeScreen', () {
    testWidgets('shows map home and find nearest button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await initLoggedInPatient();

      await tester.pumpWidget(wrapWithProviders(const PatientHomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Find Nearest Available Doctor'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('switches bottom nav tabs', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await initLoggedInPatient();

      await tester.pumpWidget(wrapWithProviders(const PatientHomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Bookings'));
      await tester.pump();
      expect(find.byType(PatientAppointmentsScreen), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pump();
      expect(find.byType(PatientHistoryScreen), findsOneWidget);

      await tester.tap(find.text('Payments'));
      await tester.pump();
      expect(find.byType(PatientPaymentsScreen), findsOneWidget);
    });
  });
}
