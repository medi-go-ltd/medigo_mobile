"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../prisma/prisma.service");
const password_reset_mailer_service_1 = require("./password-reset-mailer.service");
const email_verification_mailer_service_1 = require("./email-verification-mailer.service");
const social_token_verifier_service_1 = require("./social-token-verifier.service");
const bcrypt = __importStar(require("bcrypt"));
const client_1 = require("@prisma/client");
const token_util_1 = require("../common/utils/token.util");
let AuthService = class AuthService {
    prisma;
    jwtService;
    configService;
    passwordResetMailer;
    emailVerificationMailer;
    socialTokenVerifier;
    constructor(prisma, jwtService, configService, passwordResetMailer, emailVerificationMailer, socialTokenVerifier) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.configService = configService;
        this.passwordResetMailer = passwordResetMailer;
        this.emailVerificationMailer = emailVerificationMailer;
        this.socialTokenVerifier = socialTokenVerifier;
    }
    async registerDoctor(payload) {
        const passwordHash = await bcrypt.hash(payload.password, 10);
        const user = await this.createUserSafely({
            email: payload.email.toLowerCase(),
            firstName: payload.firstName,
            lastName: payload.lastName,
            phoneNumber: payload.phoneNumber,
            passwordHash,
            role: client_1.UserRole.DOCTOR,
            doctor: {
                create: {
                    gmcNumber: payload.gmcNumber,
                    specialisations: payload.specialisations,
                    yearsOfExperience: payload.yearsOfExperience,
                    consultationFee: payload.consultationFee,
                    callOutFee: payload.callOutFee,
                    radiusKm: payload.radiusKm,
                    homeAddress: payload.homeAddress,
                },
            },
        });
        return this.issueAuthResponse(user, 'Doctor registration successful');
    }
    async registerPatient(payload) {
        const passwordHash = await bcrypt.hash(payload.password, 10);
        const user = await this.createUserSafely({
            email: payload.email.toLowerCase(),
            firstName: payload.firstName,
            lastName: payload.lastName,
            phoneNumber: payload.phoneNumber,
            passwordHash,
            role: client_1.UserRole.PATIENT,
            verificationStatus: client_1.VerificationStatus.APPROVED,
            emailVerifiedAt: null,
            patient: {
                create: {
                    dateOfBirth: payload.dateOfBirth
                        ? new Date(payload.dateOfBirth)
                        : null,
                    gender: payload.gender,
                    genderAtBirth: payload.genderAtBirth,
                    houseNumber: payload.address?.houseNumber,
                    street: payload.address?.street,
                    postcode: payload.address?.postcode,
                    highBloodPressure: payload.medicalHistory?.highBloodPressure ?? false,
                    diabetes: payload.medicalHistory?.diabetes ?? false,
                    heartDisease: payload.medicalHistory?.heartDisease ?? false,
                    asthma: payload.medicalHistory?.asthma ?? false,
                    allergies: payload.medicalHistory?.allergies ?? false,
                    allergyDetails: payload.medicalHistory?.allergyDetails,
                    currentMedications: payload.medicalHistory?.currentMedications,
                    additionalNotes: payload.medicalHistory?.additionalNotes,
                    sameGenderDoctorPreference: payload.preferences?.sameGenderDoctorPreference ?? false,
                    locationServicesEnabled: payload.preferences?.locationServicesEnabled ?? true,
                },
            },
        });
        await this.createAndSendEmailVerification(user.id, user.email);
        return this.issueAuthResponse(user, 'Registration successful. Please verify your email.');
    }
    async socialSignIn(payload) {
        if (payload.role !== 'patient') {
            throw new common_1.BadRequestException('Social sign-in is only available for patients');
        }
        const claims = await this.socialTokenVerifier.verify(payload.provider, payload.idToken, { rawNonce: payload.nonce, insecureFallbackEmail: payload.email });
        const email = claims.email?.toLowerCase();
        if (!email) {
            throw new common_1.BadRequestException('Email is required for social sign-in. Try again or use email signup.');
        }
        if (!claims.emailVerified) {
            throw new common_1.UnauthorizedException('Your email is not verified with this provider. Use email signup instead.');
        }
        const providerSubject = claims.sub;
        const existingByProvider = await this.prisma.user.findFirst({
            where: {
                authProvider: payload.provider,
                providerSubject,
            },
        });
        if (existingByProvider) {
            if (existingByProvider.role !== client_1.UserRole.PATIENT) {
                throw new common_1.ConflictException('This social account is linked to a non-patient user');
            }
            const refreshed = existingByProvider.emailVerifiedAt == null
                ? await this.prisma.user.update({
                    where: { id: existingByProvider.id },
                    data: { emailVerifiedAt: new Date() },
                })
                : existingByProvider;
            return this.issueAuthResponse(refreshed, 'Login successful');
        }
        const existingByEmail = await this.prisma.user.findUnique({
            where: { email },
        });
        if (existingByEmail) {
            if (existingByEmail.role !== client_1.UserRole.PATIENT) {
                throw new common_1.ConflictException('An account with this email already exists for a different role. Sign in with email instead.');
            }
            const updated = await this.prisma.user.update({
                where: { id: existingByEmail.id },
                data: {
                    authProvider: payload.provider,
                    providerSubject,
                    emailVerifiedAt: existingByEmail.emailVerifiedAt ?? new Date(),
                },
            });
            return this.issueAuthResponse(updated, 'Login successful');
        }
        const user = await this.createUserSafely({
            email,
            firstName: payload.firstName ?? claims.firstName ?? 'Patient',
            lastName: payload.lastName ?? claims.lastName ?? '',
            passwordHash: null,
            role: client_1.UserRole.PATIENT,
            authProvider: payload.provider,
            providerSubject,
            verificationStatus: client_1.VerificationStatus.APPROVED,
            emailVerifiedAt: new Date(),
            patient: {
                create: {},
            },
        });
        return this.issueAuthResponse(user, 'Registration successful');
    }
    async verifyEmail(payload) {
        const email = payload.email.toLowerCase();
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (!user) {
            throw new common_1.BadRequestException('Invalid verification code');
        }
        if (user.emailVerifiedAt) {
            throw new common_1.BadRequestException('This email is already verified. Please sign in.');
        }
        const codeHash = (0, token_util_1.hashEmailVerificationCode)(payload.code);
        const record = await this.prisma.emailVerification.findFirst({
            where: { userId: user.id, codeHash },
            orderBy: { createdAt: 'desc' },
        });
        if (!record || record.expiresAt < new Date()) {
            if (record) {
                await this.prisma.emailVerification.delete({ where: { id: record.id } });
            }
            throw new common_1.BadRequestException('Invalid or expired verification code');
        }
        const updated = await this.prisma.user.update({
            where: { id: user.id },
            data: { emailVerifiedAt: new Date() },
        });
        await this.prisma.emailVerification.deleteMany({
            where: { userId: user.id },
        });
        return this.issueAuthResponse(updated, 'Email verified successfully');
    }
    async resendEmailVerification(payload) {
        const email = payload.email.toLowerCase();
        const user = await this.prisma.user.findUnique({ where: { email } });
        const message = 'If an account exists for this email, a new verification code has been sent.';
        if (!user || user.emailVerifiedAt) {
            return { success: true, message };
        }
        await this.createAndSendEmailVerification(user.id, user.email);
        return { success: true, message };
    }
    async login(payload) {
        const user = await this.prisma.user.findUnique({
            where: { email: payload.email.toLowerCase() },
        });
        if (!user || !user.passwordHash) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const valid = await bcrypt.compare(payload.password, user.passwordHash);
        if (!valid) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        return this.issueAuthResponse(user, 'Login successful');
    }
    async refresh(payload) {
        const tokenHash = (0, token_util_1.hashRefreshToken)(payload.refreshToken);
        const session = await this.prisma.session.findFirst({
            where: { refreshTokenHash: tokenHash },
            include: { user: true },
        });
        if (!session || session.expiresAt < new Date()) {
            if (session) {
                await this.prisma.session.delete({ where: { id: session.id } });
            }
            throw new common_1.UnauthorizedException('Invalid or expired refresh token');
        }
        await this.prisma.session.delete({ where: { id: session.id } });
        return this.issueAuthResponse(session.user, 'Token refreshed');
    }
    async logout(payload) {
        const tokenHash = (0, token_util_1.hashRefreshToken)(payload.refreshToken);
        await this.prisma.session.deleteMany({
            where: { refreshTokenHash: tokenHash },
        });
        return { success: true, message: 'Logged out' };
    }
    async forgotPassword(payload) {
        const email = payload.email.toLowerCase();
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (user) {
            await this.prisma.passwordReset.deleteMany({
                where: { userId: user.id },
            });
            const token = (0, token_util_1.generatePasswordResetToken)();
            const expiresIn = this.configService.get('PASSWORD_RESET_EXPIRES_IN') ?? '1h';
            await this.prisma.passwordReset.create({
                data: {
                    userId: user.id,
                    tokenHash: (0, token_util_1.hashPasswordResetToken)(token),
                    expiresAt: (0, token_util_1.expiresAtFromDuration)(expiresIn),
                },
            });
            this.passwordResetMailer.sendPasswordResetEmail(user.email, token);
        }
        return {
            success: true,
            message: 'If an account exists for this email, you will receive password reset instructions shortly.',
        };
    }
    async resetPassword(payload) {
        const email = payload.email.toLowerCase();
        const user = await this.prisma.user.findUnique({ where: { email } });
        if (!user) {
            throw new common_1.BadRequestException('Invalid or expired reset token');
        }
        const tokenHash = (0, token_util_1.hashPasswordResetToken)(payload.token);
        const resetRecord = await this.prisma.passwordReset.findFirst({
            where: { userId: user.id, tokenHash },
            orderBy: { createdAt: 'desc' },
        });
        if (!resetRecord || resetRecord.expiresAt < new Date()) {
            if (resetRecord) {
                await this.prisma.passwordReset.delete({
                    where: { id: resetRecord.id },
                });
            }
            throw new common_1.BadRequestException('Invalid or expired reset token');
        }
        const passwordHash = await bcrypt.hash(payload.password, 10);
        await this.prisma.$transaction([
            this.prisma.user.update({
                where: { id: user.id },
                data: { passwordHash },
            }),
            this.prisma.passwordReset.deleteMany({ where: { userId: user.id } }),
            this.prisma.session.deleteMany({ where: { userId: user.id } }),
        ]);
        return {
            success: true,
            message: 'Password updated successfully. You can sign in with your new password.',
        };
    }
    async createUserSafely(data) {
        try {
            const { verificationStatus, ...rest } = data;
            return await this.prisma.user.create({
                data: {
                    ...rest,
                    verificationStatus: verificationStatus ?? client_1.VerificationStatus.PENDING,
                },
            });
        }
        catch (error) {
            if (typeof error === 'object' &&
                error !== null &&
                'code' in error &&
                error.code === 'P2002') {
                throw new common_1.ConflictException('Email already registered');
            }
            throw error;
        }
    }
    async createAndSendEmailVerification(userId, email) {
        await this.prisma.emailVerification.deleteMany({ where: { userId } });
        const code = (0, token_util_1.generateEmailVerificationCode)();
        const expiresIn = this.configService.get('EMAIL_VERIFICATION_EXPIRES_IN') ?? '30m';
        await this.prisma.emailVerification.create({
            data: {
                userId,
                codeHash: (0, token_util_1.hashEmailVerificationCode)(code),
                expiresAt: (0, token_util_1.expiresAtFromDuration)(expiresIn),
            },
        });
        this.emailVerificationMailer.sendVerificationEmail(email, code);
    }
    async issueAuthResponse(user, message) {
        const accessToken = await this.issueAccessToken(user.id, user.email, user.role);
        const refreshToken = await this.createRefreshSession(user.id);
        const patient = user.role === client_1.UserRole.PATIENT
            ? await this.prisma.patient.findUnique({ where: { userId: user.id } })
            : null;
        return {
            success: true,
            message,
            refreshToken,
            user: {
                id: user.id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                phoneNumber: user.phoneNumber,
                role: user.role.toLowerCase(),
                gender: patient?.gender ?? null,
                profileImageUrl: user.profileImageUrl,
                verificationStatus: user.verificationStatus.toLowerCase(),
                emailVerified: user.emailVerifiedAt != null,
                token: accessToken,
            },
        };
    }
    async createRefreshSession(userId) {
        const refreshToken = (0, token_util_1.generateRefreshToken)();
        const refreshExpiresIn = this.configService.getOrThrow('JWT_REFRESH_EXPIRES_IN');
        await this.prisma.session.create({
            data: {
                userId,
                refreshTokenHash: (0, token_util_1.hashRefreshToken)(refreshToken),
                expiresAt: (0, token_util_1.expiresAtFromDuration)(refreshExpiresIn),
            },
        });
        return refreshToken;
    }
    async issueAccessToken(userId, email, role) {
        return this.jwtService.signAsync({
            sub: userId,
            email,
            role,
        }, {
            secret: this.configService.getOrThrow('JWT_SECRET'),
            expiresIn: this.configService.getOrThrow('JWT_EXPIRES_IN'),
        });
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService,
        config_1.ConfigService,
        password_reset_mailer_service_1.PasswordResetMailerService,
        email_verification_mailer_service_1.EmailVerificationMailerService,
        social_token_verifier_service_1.SocialTokenVerifierService])
], AuthService);
//# sourceMappingURL=auth.service.js.map