import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDoctorDto } from './dto/register-doctor.dto';
import { RegisterPatientDto } from './dto/register-patient.dto';
import { SocialSignInDto } from './dto/social-sign-in.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { ResendEmailVerificationDto } from './dto/resend-email-verification.dto';
import { PasswordResetMailerService } from './password-reset-mailer.service';
import { EmailVerificationMailerService } from './email-verification-mailer.service';
import { SocialTokenVerifierService } from './social-token-verifier.service';
export declare class AuthService {
    private readonly prisma;
    private readonly jwtService;
    private readonly configService;
    private readonly passwordResetMailer;
    private readonly emailVerificationMailer;
    private readonly socialTokenVerifier;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService, passwordResetMailer: PasswordResetMailerService, emailVerificationMailer: EmailVerificationMailerService, socialTokenVerifier: SocialTokenVerifierService);
    registerDoctor(payload: RegisterDoctorDto): Promise<{
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
    registerPatient(payload: RegisterPatientDto): Promise<{
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
    socialSignIn(payload: SocialSignInDto): Promise<{
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
    verifyEmail(payload: VerifyEmailDto): Promise<{
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
    resendEmailVerification(payload: ResendEmailVerificationDto): Promise<{
        success: boolean;
        message: string;
    }>;
    login(payload: LoginDto): Promise<{
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
    refresh(payload: RefreshTokenDto): Promise<{
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
    logout(payload: RefreshTokenDto): Promise<{
        success: boolean;
        message: string;
    }>;
    forgotPassword(payload: ForgotPasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    resetPassword(payload: ResetPasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    private createUserSafely;
    private createAndSendEmailVerification;
    private issueAuthResponse;
    private createRefreshSession;
    private issueAccessToken;
}
