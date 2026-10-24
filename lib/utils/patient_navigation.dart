import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/services/onboarding_preferences_service.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

/// Routes authenticated patients to onboarding or home based on prefs.
Future<void> navigateAuthenticatedPatient(BuildContext context) async {
  final complete = await OnboardingPreferencesService.isOnboardingComplete();
  if (!context.mounted) return;

  if (complete) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  } else {
    Navigator.of(context).pushReplacementNamed(AppRoutes.patientOnboarding);
  }
}

/// Routes after login/signup/splash when [user] may be patient or doctor.
Future<void> navigateAfterAuth(
  BuildContext context, {
  required AuthViewModel authViewModel,
}) async {
  final user = authViewModel.user;
  if (user == null) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    return;
  }

  if (user.role == UserRole.patient && !user.emailVerified) {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.verifyEmail,
      arguments: VerifyEmailArguments(email: user.email),
    );
    return;
  }

  if (user.role == UserRole.doctor && !user.isVerified) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.verificationPending);
    return;
  }

  if (user.role == UserRole.patient) {
    await navigateAuthenticatedPatient(context);
    return;
  }

  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
}
