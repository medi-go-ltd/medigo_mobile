import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/features/auth/doctor_signup_screen.dart';
import 'package:medigo_mobile/features/auth/forgot_password_screen.dart';
import 'package:medigo_mobile/features/auth/forgot_password_sent_screen.dart';
import 'package:medigo_mobile/features/auth/login_screen.dart';
import 'package:medigo_mobile/features/auth/patient_signup_screen.dart';
import 'package:medigo_mobile/features/auth/reset_password_screen.dart';
import 'package:medigo_mobile/features/auth/verification_pending_screen.dart';
import 'package:medigo_mobile/features/home/home_screen.dart';
import 'package:medigo_mobile/features/patient/booking/patient_booking_flow_screen.dart';
import 'package:medigo_mobile/features/patient/visit/patient_active_visit_screen.dart';
import 'package:medigo_mobile/features/patient/visit/patient_rating_screen.dart';
import 'package:medigo_mobile/features/patient/visit/patient_waiting_screen.dart';
import 'package:medigo_mobile/features/patient/onboarding/patient_onboarding_screen.dart';
import 'package:medigo_mobile/features/patient/registration/patient_registration_success_screen.dart';
import 'package:medigo_mobile/features/patient/verification/patient_verification_pending_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/trusted_contacts_screen.dart';
import 'package:medigo_mobile/features/splash/splash_screen.dart';
import 'package:medigo_mobile/features/welcome/welcome_screen.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordSent = '/forgot-password-sent';
  static const String resetPassword = '/reset-password';
  static const String signup = '/signup';
  static const String doctorSignup = '/doctor-signup';
  static const String verificationPending = '/verification-pending';
  static const String patientRegistrationSuccess = '/patient-registration-success';
  static const String patientVerificationPending = '/patient-verification-pending';
  static const String patientOnboarding = '/patient-onboarding';
  static const String home = '/home';
  static const String patientBooking = '/patient-booking';
  static const String patientWaiting = '/patient-waiting';
  static const String patientActiveVisit = '/patient-active-visit';
  static const String patientRating = '/patient-rating';
  static const String patientTrustedContacts = '/patient-trusted-contacts';

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
      case forgotPassword:
        final args = settings.arguments as ForgotPasswordArguments?;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(initialEmail: args?.email),
          settings: settings,
        );
      case forgotPasswordSent:
        final args = settings.arguments as ForgotPasswordSentArguments?;
        if (args == null) {
          return _errorRoute(settings, 'Email required');
        }
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordSentScreen(email: args.email),
          settings: settings,
        );
      case resetPassword:
        final args = settings.arguments as ResetPasswordArguments?;
        if (args == null) {
          return _errorRoute(settings, 'Email required for password reset');
        }
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: args.email,
            initialToken: args.token,
          ),
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
          builder: (_) => const PatientSignupScreen(),
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
      case patientRegistrationSuccess:
        return MaterialPageRoute(
          builder: (_) => const PatientRegistrationSuccessScreen(),
          settings: settings,
        );
      case patientVerificationPending:
        return MaterialPageRoute(
          builder: (_) => const PatientVerificationPendingScreen(),
          settings: settings,
        );
      case patientOnboarding:
        return MaterialPageRoute(
          builder: (_) => const PatientOnboardingScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (context) => _buildHomeRoute(context),
          settings: settings,
        );
      case patientBooking:
        final args = settings.arguments as PatientBookingArguments?;
        if (args == null) {
          return _errorRoute(settings, 'Doctor required for booking');
        }
        return MaterialPageRoute(
          builder: (_) => PatientBookingFlowScreen(
            doctor: args.doctor,
            isNearestDoctor: args.isNearestDoctor,
          ),
          settings: settings,
        );
      case patientWaiting:
        final bookingId = settings.arguments as String?;
        if (bookingId == null) {
          return _errorRoute(settings, 'Booking ID required');
        }
        return MaterialPageRoute(
          builder: (_) => PatientWaitingScreen(bookingId: bookingId),
          settings: settings,
        );
      case patientActiveVisit:
        final bookingId = settings.arguments as String?;
        if (bookingId == null) {
          return _errorRoute(settings, 'Booking ID required');
        }
        return MaterialPageRoute(
          builder: (_) => PatientActiveVisitScreen(bookingId: bookingId),
          settings: settings,
        );
      case patientRating:
        final bookingId = settings.arguments as String?;
        if (bookingId == null) {
          return _errorRoute(settings, 'Booking ID required');
        }
        return MaterialPageRoute(
          builder: (_) => PatientRatingScreen(bookingId: bookingId),
          settings: settings,
        );
      case patientTrustedContacts:
        return MaterialPageRoute(
          builder: (_) => const TrustedContactsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }

  static Widget _buildHomeRoute(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.user;
    if (user != null && !user.isVerified) {
      if (user.role == UserRole.doctor) {
        return const VerificationPendingScreen();
      }
      return const PatientVerificationPendingScreen();
    }
    return const HomeScreen();
  }

  static MaterialPageRoute<dynamic> _errorRoute(
    RouteSettings settings,
    String message,
  ) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text(message)),
      ),
      settings: settings,
    );
  }
}

class LoginArguments {
  final UserRole role;

  const LoginArguments({required this.role});
}

class ForgotPasswordArguments {
  final String? email;

  const ForgotPasswordArguments({this.email});
}

class ForgotPasswordSentArguments {
  final String email;

  const ForgotPasswordSentArguments({required this.email});
}

class ResetPasswordArguments {
  final String email;
  final String? token;

  const ResetPasswordArguments({required this.email, this.token});
}

class SignupArguments {
  final UserRole role;

  const SignupArguments({required this.role});
}

class PatientBookingArguments {
  final Doctor doctor;
  final bool isNearestDoctor;

  const PatientBookingArguments({
    required this.doctor,
    this.isNearestDoctor = false,
  });
}
