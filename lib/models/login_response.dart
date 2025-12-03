import 'package:medigo_mobile/models/user.dart';

class LoginResponse {
  final User user;
  final String message;
  final bool success;

  LoginResponse({
    required this.user,
    required this.message,
    required this.success,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? json),
      message: json['message'] as String? ?? 'Login successful',
      success: json['success'] as bool? ?? true,
    );
  }
}
