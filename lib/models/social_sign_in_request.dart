enum SocialProvider { google, apple }

class SocialSignInRequest {
  final SocialProvider provider;
  final String idToken;
  final String role;
  final String? email;
  final String? firstName;
  final String? lastName;

  /// Raw (unhashed) Apple nonce; the backend checks its SHA-256 against the token.
  final String? nonce;

  const SocialSignInRequest({
    required this.provider,
    required this.idToken,
    required this.role,
    this.email,
    this.firstName,
    this.lastName,
    this.nonce,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'idToken': idToken,
      'role': role,
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (nonce != null) 'nonce': nonce,
    };
  }
}
