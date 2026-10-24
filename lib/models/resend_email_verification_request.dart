class ResendEmailVerificationRequest {
  final String email;

  const ResendEmailVerificationRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
