/// Data model for doctor registration ( Steps 1 & 2).
/// File paths are local paths after image/document picker selection.
class DoctorRegistrationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? profileImagePath;
  final String homeAddress;
  final String gmcNumber;
  final List<String> specialisations;
  final int yearsOfExperience;
  final double consultationFee;
  final double? callOutFee;
  final double radiusKm;
  final List<String> qualificationsFilePaths;
  final String? photoIdFilePath;
  final bool dbsConsentGiven;

  DoctorRegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.profileImagePath,
    required this.homeAddress,
    required this.gmcNumber,
    required this.specialisations,
    required this.yearsOfExperience,
    required this.consultationFee,
    this.callOutFee,
    required this.radiusKm,
    required this.qualificationsFilePaths,
    this.photoIdFilePath,
    required this.dbsConsentGiven,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'profileImagePath': profileImagePath,
      'homeAddress': homeAddress,
      'gmcNumber': gmcNumber,
      'specialisations': specialisations,
      'yearsOfExperience': yearsOfExperience,
      'consultationFee': consultationFee,
      'callOutFee': callOutFee,
      'radiusKm': radiusKm,
      'qualificationsFilePaths': qualificationsFilePaths,
      'photoIdFilePath': photoIdFilePath,
      'dbsConsentGiven': dbsConsentGiven,
    };
  }
}
