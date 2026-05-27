import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_home_screen.dart';
import 'package:medigo_mobile/features/home/patient/patient_home_screen.dart';
import 'package:medigo_mobile/features/patient/onboarding/patient_onboarding_screen.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/services/onboarding_preferences_service.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checkingOnboarding = true;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final user = context.read<AuthViewModel>().user;
    if (user?.role == UserRole.patient) {
      final complete = await OnboardingPreferencesService.isOnboardingComplete();
      if (mounted) {
        setState(() {
          _needsOnboarding = !complete;
          _checkingOnboarding = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _checkingOnboarding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingOnboarding) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_needsOnboarding) {
      return const PatientOnboardingScreen();
    }

    final user = context.watch<AuthViewModel>().user;

    if (user?.role == UserRole.patient) {
      return const PatientHomeScreen();
    }

    return const DoctorHomeScreen();
  }
}
