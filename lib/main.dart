import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medigo_mobile/constants/app_branding.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/date_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders.wrapWithProviders(
      child: MaterialApp(
        title: kAppDisplayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: UkDateUtils.ukLocale,
        supportedLocales: const [UkDateUtils.ukLocale],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
