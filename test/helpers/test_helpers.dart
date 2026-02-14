import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/user.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/models/verification_status.dart';
import 'package:medigo_mobile/providers/app_providers.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initLoggedInDoctor() async {
  final user = User(
    id: 'test-doctor-id',
    email: 'doctor@test.com',
    firstName: 'Test',
    lastName: 'Doctor',
    role: UserRole.doctor,
    verificationStatus: VerificationStatus.approved,
  );
  await _initUser(user, 'test-token');
}

Future<void> initLoggedInPatient() async {
  final user = User(
    id: 'test-patient-id',
    email: 'patient@test.com',
    firstName: 'Test',
    lastName: 'Patient',
    role: UserRole.patient,
    verificationStatus: VerificationStatus.approved,
  );
  await _initUser(user, 'test-token');
}

Future<void> _initUser(User user, String token) async {
  SharedPreferences.setMockInitialValues({
    'auth_token': token,
    'user_data': jsonEncode(user.toJson()),
    'is_logged_in': true,
  });
}

/// Clears auth state. Call before tests that need no user.
Future<void> clearAuthState() async {
  SharedPreferences.setMockInitialValues({});
}

Widget wrapWithProviders(Widget child) {
  return AppProviders.wrapWithProviders(
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}
