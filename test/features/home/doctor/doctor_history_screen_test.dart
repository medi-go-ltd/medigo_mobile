import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_history_screen.dart';
import '../../../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initLoggedInDoctor();
  });

  group('DoctorHistoryScreen Tests', () {
    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorHistoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('displays completed visits section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorHistoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your completed visits'), findsOneWidget);
    });

    testWidgets('shows content area', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(const DoctorHistoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DoctorHistoryScreen), findsOneWidget);
    });
  });
}
