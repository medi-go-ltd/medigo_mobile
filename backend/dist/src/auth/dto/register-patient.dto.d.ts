declare class AddressDto {
    houseNumber: string;
    street: string;
    postcode: string;
}
declare class MedicalHistoryDto {
    highBloodPressure?: boolean;
    diabetes?: boolean;
    heartDisease?: boolean;
    asthma?: boolean;
    allergies?: boolean;
    allergyDetails?: string;
    currentMedications?: string;
    additionalNotes?: string;
}
declare class PreferencesDto {
    sameGenderDoctorPreference?: boolean;
    locationServicesEnabled?: boolean;
}
export declare class RegisterPatientDto {
    firstName: string;
    lastName: string;
    dateOfBirth: string;
    gender: string;
    genderAtBirth: string;
    email: string;
    phoneNumber: string;
    address: AddressDto;
    password: string;
    medicalHistory?: MedicalHistoryDto;
    preferences?: PreferencesDto;
}
export {};
