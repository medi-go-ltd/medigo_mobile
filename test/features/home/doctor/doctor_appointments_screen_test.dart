import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_appointments_screen.dart';
import '../../../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initLoggedInDoctor();
  });

  group('DoctorAppointmentsScreen Tests', () {
    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorAppointmentsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appointments'), findsOneWidget);
    });

    testWidgets('displays Live, Active, Past tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorAppointmentsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
    });

    testWidgets('shows Live tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorAppointmentsScreen()),
      );
      await tester.pumpAndSettle();

      // Mock data has 2 live requests, so we see patient names
      expect(find.text('Emma Wilson'), findsOneWidget);
    });

    testWidgets('can switch to Active tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorAppointmentsScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      expect(find.text('No active visits'), findsOneWidget);
    });

    testWidgets('can switch to Past tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorAppointmentsScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Past'));
      await tester.pumpAndSettle();

      // Mock data has 2 past appointments (Sarah Mitchell, Robert Clarke)
      expect(find.text('Sarah Mitchell'), findsOneWidget);
    });
  });
}
