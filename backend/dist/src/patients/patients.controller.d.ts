import { PatientsService } from './patients.service';
import { UpdatePatientPreferencesDto } from './dto/update-patient-preferences.dto';
import type { JwtUser } from '../common/decorators/current-user.decorator';
export declare class PatientsController {
    private readonly patientsService;
    constructor(patientsService: PatientsService);
    getMe(user: JwtUser): Promise<{
        user: {
            id: string;
            email: string;
            passwordHash: string;
            firstName: string;
            lastName: string;
            phoneNumber: string | null;
            role: import("@prisma/client").$Enums.UserRole;
            profileImageUrl: string | null;
            verificationStatus: import("@prisma/client").$Enums.VerificationStatus;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        houseNumber: string;
        street: string;
        postcode: string;
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
        dateOfBirth: Date;
        gender: string;
        genderAtBirth: string;
        userId: string;
    }>;
    updatePreferences(user: JwtUser, body: UpdatePatientPreferencesDto): Promise<{
        id: string;
        houseNumber: string;
        street: string;
        postcode: string;
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
        dateOfBirth: Date;
        gender: string;
        genderAtBirth: string;
        userId: string;
    }>;
}
