import 'package:medigo_mobile/models/doctor_registration_request.dart';
import 'package:medigo_mobile/models/login_request.dart';
import 'package:medigo_mobile/models/login_response.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> registerDoctor(DoctorRegistrationRequest request);
}
