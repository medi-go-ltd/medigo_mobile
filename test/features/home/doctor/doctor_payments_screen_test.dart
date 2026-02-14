import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_payments_screen.dart';
import '../../../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initLoggedInDoctor();
  });

  group('DoctorPaymentsScreen Tests', () {
    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorPaymentsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payments'), findsOneWidget);
    });

    testWidgets('displays Total Earnings card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorPaymentsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Earnings'), findsOneWidget);
    });

    testWidgets('displays Earnings over time section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorPaymentsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Earnings over time'), findsOneWidget);
    });

    testWidgets('displays Payment History section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorPaymentsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment History'), findsOneWidget);
    });
  });
}
