import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/features/splash/splash_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() {
  group('SplashScreen Tests', () {
    testWidgets('displays logo and app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
      );
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Medi-Go'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('has white background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.surface);
    });
  });
}
