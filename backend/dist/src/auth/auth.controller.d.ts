import { AuthService } from './auth.service';
import { RegisterDoctorDto } from './dto/register-doctor.dto';
import { RegisterPatientDto } from './dto/register-patient.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { SocialSignInDto } from './dto/social-sign-in.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { ResendEmailVerificationDto } from './dto/resend-email-verification.dto';
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
            gender: string | null;
            profileImageUrl: string | null;
            verificationStatus: string;
            emailVerified: boolean;
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
            gender: string | null;
            profileImageUrl: string | null;
            verificationStatus: string;
            emailVerified: boolean;
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
            gender: string | null;
            profileImageUrl: string | null;
            verificationStatus: string;
            emailVerified: boolean;
            token: string;
        };
    }>;
    socialSignIn(body: SocialSignInDto): Promise<{
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
            gender: string | null;
            profileImageUrl: string | null;
            verificationStatus: string;
            emailVerified: boolean;
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
            gender: string | null;
            profileImageUrl: string | null;
            verificationStatus: string;
            emailVerified: boolean;
            token: string;
        };
    }>;
    logout(body: RefreshTokenDto): Promise<{
        success: boolean;
        message: string;
    }>;
    forgotPassword(body: ForgotPasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    resetPassword(body: ResetPasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    verifyEmail(body: VerifyEmailDto): Promise<{
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
            gender: string | null;
            profileImageUrl: string | null;
            verificationStatus: string;
            emailVerified: boolean;
            token: string;
        };
    }>;
    resendEmailVerification(body: ResendEmailVerificationDto): Promise<{
        success: boolean;
        message: string;
    }>;
}
