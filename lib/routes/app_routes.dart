import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/auth/login_screen.dart';
import 'package:medigo_mobile/features/auth/signup_screen.dart';
import 'package:medigo_mobile/features/splash/splash_screen.dart';
import 'package:medigo_mobile/features/welcome/welcome_screen.dart';
import 'package:medigo_mobile/models/user_role.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      case login:
        final args = settings.arguments as LoginArguments?;
        final role = args?.role ?? UserRole.patient;
        return MaterialPageRoute(
          builder: (_) => LoginScreen(role: role),
          settings: settings,
        );
      case signup:
        final args = settings.arguments as SignupArguments?;
        final role = args?.role ?? UserRole.patient;
        return MaterialPageRoute(
          builder: (_) => SignupScreen(role: role),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}

class LoginArguments {
  final UserRole role;

  const LoginArguments({required this.role});
}

class SignupArguments {
  final UserRole role;

  const SignupArguments({required this.role});
}
