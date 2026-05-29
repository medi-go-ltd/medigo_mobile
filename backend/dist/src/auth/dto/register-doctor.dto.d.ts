export declare class RegisterDoctorDto {
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string;
    password: string;
    homeAddress: string;
    gmcNumber: string;
    specialisations: string[];
    yearsOfExperience: number;
    consultationFee: number;
    callOutFee?: number;
    radiusKm: number;
    qualificationsFilePaths: string[];
    photoIdFilePath?: string;
    dbsConsentGiven: boolean;
}
