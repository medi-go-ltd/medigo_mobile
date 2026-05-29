import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDoctorDto } from './dto/register-doctor.dto';
import { RegisterPatientDto } from './dto/register-patient.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
export declare class AuthService {
    private readonly prisma;
    private readonly jwtService;
    private readonly configService;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService);
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
            verificationStatus: string;
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
            verificationStatus: string;
            token: string;
        };
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
            verificationStatus: string;
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
            verificationStatus: string;
            token: string;
        };
    }>;
    logout(payload: RefreshTokenDto): Promise<{
        success: boolean;
        message: string;
    }>;
    private createUserSafely;
    private issueAuthResponse;
    private createRefreshSession;
    private issueAccessToken;
}
