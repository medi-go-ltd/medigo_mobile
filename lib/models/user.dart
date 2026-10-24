import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/models/verification_status.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;
  final String? gender;
  final String? profileImageUrl;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VerificationStatus verificationStatus;
  final bool emailVerified;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    this.gender,
    this.profileImageUrl,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.verificationStatus = VerificationStatus.pending,
    this.emailVerified = true,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName:
          json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName:
          json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone_number'] as String?,
      role: _parseRole(json['role'] as String?),
      gender: json['gender'] as String? ?? json['gender_at_birth'] as String?,
      profileImageUrl:
          json['profileImageUrl'] as String? ??
          json['profile_image_url'] as String?,
      token: json['token'] as String? ?? json['access_token'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      verificationStatus: VerificationStatus.parse(
        json['verificationStatus'] as String? ??
            json['verification_status'] as String?,
      ),
      emailVerified:
          json['emailVerified'] as bool? ??
          json['email_verified'] as bool? ??
          true,
    );
  }

  bool get isVerified => verificationStatus == VerificationStatus.approved;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'gender': gender,
      'profileImageUrl': profileImageUrl,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'verificationStatus': verificationStatus.name,
      'emailVerified': emailVerified,
    };
  }

  static UserRole _parseRole(String? roleString) {
    if (roleString == null) return UserRole.patient;
    switch (roleString.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      case 'patient':
        return UserRole.patient;
      default:
        return UserRole.patient;
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
    String? gender,
    String? profileImageUrl,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    VerificationStatus? verificationStatus,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
