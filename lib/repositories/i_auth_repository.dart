import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/models/login_request.dart';
import 'package:medigo_mobile/models/login_response.dart';
import 'package:medigo_mobile/models/patient_registration_request.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> registerDoctor(DoctorRegistrationRequest request);
  Future<LoginResponse> registerPatient(PatientRegistrationRequest request);
}
