import { AuthService } from './auth.service';
import { RegisterDoctorDto } from './dto/register-doctor.dto';
import { RegisterPatientDto } from './dto/register-patient.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    registerDoctor(body: RegisterDoctorDto): Promise<{
        success: boolean;
        message: string;
        refreshToken: string;
        user: {
            id: string;
            email: string;
            firstName: string;
            lastName: string;
            phoneNumber: string | null;
            role: string;
            verificationStatus: string;
            token: string;
        };
    }>;
    registerPatient(body: RegisterPatientDto): Promise<{
        success: boolean;
        message: string;
        refreshToken: string;
        user: {
            id: string;
            email: string;
            firstName: string;
            lastName: string;
            phoneNumber: string | null;
            role: string;
            verificationStatus: string;
            token: string;
        };
    }>;
    login(body: LoginDto): Promise<{
        success: boolean;
        message: string;
        refreshToken: string;
        user: {
            id: string;
            email: string;
            firstName: string;
            lastName: string;
            phoneNumber: string | null;
            role: string;
            verificationStatus: string;
            token: string;
        };
    }>;
    refresh(body: RefreshTokenDto): Promise<{
        success: boolean;
        message: string;
        refreshToken: string;
        user: {
            id: string;
            email: string;
            firstName: string;
            lastName: string;
            phoneNumber: string | null;
            role: string;
            verificationStatus: string;
            token: string;
        };
    }>;
    logout(body: RefreshTokenDto): Promise<{
        success: boolean;
        message: string;
    }>;
}
