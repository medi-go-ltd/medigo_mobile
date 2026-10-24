import { PrismaService } from '../prisma/prisma.service';
import { UpdatePatientPreferencesDto } from './dto/update-patient-preferences.dto';
export declare class PatientsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getMe(userId: string): Promise<{
        user: {
            id: string;
            email: string;
            passwordHash: string | null;
            firstName: string;
            lastName: string;
            phoneNumber: string | null;
            role: import("@prisma/client").$Enums.UserRole;
            profileImageUrl: string | null;
            authProvider: string | null;
            providerSubject: string | null;
            verificationStatus: import("@prisma/client").$Enums.VerificationStatus;
            emailVerifiedAt: Date | null;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        houseNumber: string | null;
        street: string | null;
        postcode: string | null;
        highBloodPressure: boolean;
        diabetes: boolean;
        heartDisease: boolean;
        asthma: boolean;
        allergies: boolean;
        allergyDetails: string | null;
        currentMedications: string | null;
        additionalNotes: string | null;
        sameGenderDoctorPreference: boolean;
        locationServicesEnabled: boolean;
        dateOfBirth: Date | null;
        gender: string | null;
        genderAtBirth: string | null;
        userId: string;
    }>;
    updatePreferences(userId: string, payload: UpdatePatientPreferencesDto): Promise<{
        id: string;
        houseNumber: string | null;
        street: string | null;
        postcode: string | null;
        highBloodPressure: boolean;
        diabetes: boolean;
        heartDisease: boolean;
        asthma: boolean;
        allergies: boolean;
        allergyDetails: string | null;
        currentMedications: string | null;
        additionalNotes: string | null;
        sameGenderDoctorPreference: boolean;
        locationServicesEnabled: boolean;
        dateOfBirth: Date | null;
        gender: string | null;
        genderAtBirth: string | null;
        userId: string;
    }>;
}
