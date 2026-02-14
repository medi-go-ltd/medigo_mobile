import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_home_screen.dart';
import 'package:medigo_mobile/features/home/home_screen.dart';
import 'package:medigo_mobile/features/home/patient/patient_home_screen.dart';
import '../../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomeScreen Tests', () {
    testWidgets('shows DoctorHomeScreen when user is doctor', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await initLoggedInDoctor();

      await tester.pumpWidget(wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorHomeScreen), findsOneWidget);
    });

    testWidgets('shows PatientHomeScreen when user is patient', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await initLoggedInPatient();

      await tester.pumpWidget(wrapWithProviders(const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PatientHomeScreen), findsOneWidget);
    });

    testWidgets('shows DoctorHomeScreen when user is null (default)', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(DoctorHomeScreen), findsOneWidget);
    });
  });
}
