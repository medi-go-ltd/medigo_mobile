import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/main.dart';
import 'package:medigo_mobile/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App initializes and shows splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
