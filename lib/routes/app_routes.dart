import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/features/auth/doctor_signup_screen.dart';
import 'package:medigo_mobile/features/auth/login_screen.dart';
import 'package:medigo_mobile/features/auth/signup_screen.dart';
import 'package:medigo_mobile/features/auth/verification_pending_screen.dart';
import 'package:medigo_mobile/features/home/home_screen.dart';
import 'package:medigo_mobile/features/home/patient_home_screen.dart';
import 'package:medigo_mobile/features/splash/splash_screen.dart';
import 'package:medigo_mobile/features/welcome/welcome_screen.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String doctorSignup = '/doctor-signup';
  static const String verificationPending = '/verification-pending';
  static const String home = '/home';

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
        if (role == UserRole.doctor) {
          return MaterialPageRoute(
            builder: (_) => const DoctorSignupScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => SignupScreen(role: role),
          settings: settings,
        );
      case doctorSignup:
        return MaterialPageRoute(
          builder: (_) => const DoctorSignupScreen(),
          settings: settings,
        );
      case verificationPending:
        return MaterialPageRoute(
          builder: (_) => const VerificationPendingScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (context) {
            final authViewModel = Provider.of<AuthViewModel>(
              context,
              listen: false,
            );
            final user = authViewModel.user;
            if (user != null &&
                user.role == UserRole.doctor &&
                !user.isVerified) {
              return const VerificationPendingScreen();
            }
            if (user?.role == UserRole.patient) {
              return const PatientHomeScreen();
            }
            return const HomeScreen();
          },
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
