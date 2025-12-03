import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/services/firebase_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (non-blocking - app will work even if Firebase fails)
  try {
    final firebaseInitialized = await FirebaseService.initialize();
    if (!firebaseInitialized) {
      // Log error but continue - app can work without Firebase for now
      debugPrint('Warning: Firebase initialization failed. App will continue without Firebase features.');
    }
  } catch (e) {
    // Catch any unexpected errors during initialization
    debugPrint('Error during Firebase initialization: $e');
  }

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
        title: 'Medi Go',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
