class PatientRegistrationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? dateOfBirth;
  final String? gender;
  final String? genderAtBirth;
  final String? phoneNumber;
  final String? houseNumber;
  final String? street;
  final String? postcode;
  final String? profileImagePath;
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
    required this.email,
    required this.password,
    this.dateOfBirth,
    this.gender,
    this.genderAtBirth,
    this.phoneNumber,
    this.houseNumber,
    this.street,
    this.postcode,
    this.profileImagePath,
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
    final json = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'preferences': {
        'sameGenderDoctorPreference': sameGenderDoctorPreference,
        'locationServicesEnabled': locationServicesEnabled,
      },
    };

    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      json['dateOfBirth'] = dateOfBirth;
    }
    if (gender != null && gender!.isNotEmpty) {
      json['gender'] = gender;
    }
    if (genderAtBirth != null && genderAtBirth!.isNotEmpty) {
      json['genderAtBirth'] = genderAtBirth;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      json['phoneNumber'] = phoneNumber;
    }

    final hasAddress =
        (houseNumber != null && houseNumber!.isNotEmpty) ||
        (street != null && street!.isNotEmpty) ||
        (postcode != null && postcode!.isNotEmpty);
    if (hasAddress) {
      json['address'] = {
        if (houseNumber != null) 'houseNumber': houseNumber,
        if (street != null) 'street': street,
        if (postcode != null) 'postcode': postcode,
      };
    }

    json['medicalHistory'] = {
      'highBloodPressure': highBloodPressure,
      'diabetes': diabetes,
      'heartDisease': heartDisease,
      'asthma': asthma,
      'allergies': allergies,
      'allergyDetails': allergyDetails,
      'currentMedications': currentMedications,
      'additionalNotes': additionalNotes,
    };

    return json;
  }
}
