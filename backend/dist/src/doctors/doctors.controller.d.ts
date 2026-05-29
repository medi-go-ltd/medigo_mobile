import { DoctorsService } from './doctors.service';
import { UpdateDoctorAvailabilityDto } from './dto/update-doctor-availability.dto';
import type { JwtUser } from '../common/decorators/current-user.decorator';
export declare class DoctorsController {
    private readonly doctorsService;
    constructor(doctorsService: DoctorsService);
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
    updateAvailability(user: JwtUser, body: UpdateDoctorAvailabilityDto): Promise<{
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
