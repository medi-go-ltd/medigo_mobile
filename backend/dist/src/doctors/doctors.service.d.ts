import { PrismaService } from '../prisma/prisma.service';
import { UpdateDoctorAvailabilityDto } from './dto/update-doctor-availability.dto';
export declare class DoctorsService {
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
        verificationStatus: import("@prisma/client").$Enums.VerificationStatus;
        homeAddress: string;
        gmcNumber: string;
        specialisations: string[];
        yearsOfExperience: number;
        consultationFee: import("@prisma/client/runtime/library").Decimal;
        callOutFee: import("@prisma/client/runtime/library").Decimal | null;
        radiusKm: import("@prisma/client/runtime/library").Decimal;
        isAvailable: boolean;
        userId: string;
    }>;
    updateAvailability(userId: string, payload: UpdateDoctorAvailabilityDto): Promise<{
        id: string;
        verificationStatus: import("@prisma/client").$Enums.VerificationStatus;
        homeAddress: string;
        gmcNumber: string;
        specialisations: string[];
        yearsOfExperience: number;
        consultationFee: import("@prisma/client/runtime/library").Decimal;
        callOutFee: import("@prisma/client/runtime/library").Decimal | null;
        radiusKm: import("@prisma/client/runtime/library").Decimal;
        isAvailable: boolean;
        userId: string;
    }>;
}
