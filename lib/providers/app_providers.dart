import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/view_models/login_view_model.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/view_models/patient_home_view_model.dart';
import 'package:medigo_mobile/view_models/signup_view_model.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
    ChangeNotifierProvider<LoginViewModel>(
      create: (context) =>
          LoginViewModel(authViewModel: context.read<AuthViewModel>()),
    ),
    ChangeNotifierProvider<SignupViewModel>(
      create: (context) =>
          SignupViewModel(authViewModel: context.read<AuthViewModel>()),
    ),
    ChangeNotifierProvider<PatientHomeViewModel>(
      create: (_) => PatientHomeViewModel(),
    ),
    ChangeNotifierProvider<DoctorHomeViewModel>(
      create: (_) => DoctorHomeViewModel(),
    ),
    ChangeNotifierProvider<PatientBookingViewModel>(
      create: (context) => PatientBookingViewModel(
        doctorHomeViewModel: context.read<DoctorHomeViewModel>(),
      ),
    ),
  ];

  static Widget wrapWithProviders({required Widget child}) {
    return MultiProvider(providers: providers, child: child);
  }
}
