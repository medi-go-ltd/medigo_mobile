class DoctorProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final double consultationFee;
  final double? callOutFee;
  final double radiusKm;

  DoctorProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.consultationFee,
    this.callOutFee,
    required this.radiusKm,
  });

  DoctorProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    double? consultationFee,
    double? callOutFee,
    double? radiusKm,
  }) {
    return DoctorProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      consultationFee: consultationFee ?? this.consultationFee,
      callOutFee: callOutFee ?? this.callOutFee,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}
