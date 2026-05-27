class PatientRegistrationRequest {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String genderAtBirth;
  final String? profileImagePath;
  final String email;
  final String phoneNumber;
  final String houseNumber;
  final String street;
  final String postcode;
  final String? proofOfAddressPath;
  final String? photoIdPath;
  final String password;
  final bool highBloodPressure;
  final bool diabetes;
  final bool heartDisease;
  final bool asthma;
  final bool allergies;
  final String? allergyDetails;
  final String? currentMedications;
  final String? additionalNotes;
  final bool sameGenderDoctorPreference;
  final bool locationServicesEnabled;

  PatientRegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.genderAtBirth,
    this.profileImagePath,
    required this.email,
    required this.phoneNumber,
    required this.houseNumber,
    required this.street,
    required this.postcode,
    this.proofOfAddressPath,
    this.photoIdPath,
    required this.password,
    this.highBloodPressure = false,
    this.diabetes = false,
    this.heartDisease = false,
    this.asthma = false,
    this.allergies = false,
    this.allergyDetails,
    this.currentMedications,
    this.additionalNotes,
    this.sameGenderDoctorPreference = false,
    this.locationServicesEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'genderAtBirth': genderAtBirth,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': {
        'houseNumber': houseNumber,
        'street': street,
        'postcode': postcode,
      },
      'password': password,
      'medicalHistory': {
        'highBloodPressure': highBloodPressure,
        'diabetes': diabetes,
        'heartDisease': heartDisease,
        'asthma': asthma,
        'allergies': allergies,
        'allergyDetails': allergyDetails,
        'currentMedications': currentMedications,
        'additionalNotes': additionalNotes,
      },
      'preferences': {
        'sameGenderDoctorPreference': sameGenderDoctorPreference,
        'locationServicesEnabled': locationServicesEnabled,
      },
    };
  }
}
