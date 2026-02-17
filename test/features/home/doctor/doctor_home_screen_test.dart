import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_appointments_screen.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_earnings_screen.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_home_screen.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_history_screen.dart';
import '../../../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initLoggedInDoctor();
  });

  group('DoctorHomeScreen Tests', () {
    testWidgets('displays home content with welcome text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Welcome back'), findsWidgets);
      expect(find.text('Ready to see patients?'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Appointments'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
    });

    testWidgets('navigates to Appointments when tab tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appointments'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorAppointmentsScreen), findsOneWidget);
    });

    testWidgets('navigates to History when tab tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorHistoryScreen), findsOneWidget);
    });

    testWidgets('navigates to Earnings when tab tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Earnings'));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorEarningsScreen), findsOneWidget);
    });

    testWidgets('displays Live Requests section', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Live Requests'), findsOneWidget);
    });

    testWidgets('displays Set Radius button', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const DoctorHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Set Radius'), findsOneWidget);
    });
  });
}
