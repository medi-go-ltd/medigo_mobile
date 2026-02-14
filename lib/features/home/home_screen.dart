import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_home_screen.dart';
import 'package:medigo_mobile/features/home/patient/patient_home_screen.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    if (user?.role == UserRole.patient) {
      return const PatientHomeScreen();
    }

    return const DoctorHomeScreen();
  }
}
