import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDoctorDto } from './dto/register-doctor.dto';
import { RegisterPatientDto } from './dto/register-patient.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { PasswordResetMailerService } from './password-reset-mailer.service';
import * as bcrypt from 'bcrypt';
import { UserRole, VerificationStatus, type User } from '@prisma/client';
import {
  expiresAtFromDuration,
  generatePasswordResetToken,
  generateRefreshToken,
  hashPasswordResetToken,
  hashRefreshToken,
} from '../common/utils/token.util';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly passwordResetMailer: PasswordResetMailerService,
  ) {}

  async registerDoctor(payload: RegisterDoctorDto) {
    const passwordHash = await bcrypt.hash(payload.password, 10);
    const user = await this.createUserSafely({
      email: payload.email.toLowerCase(),
      firstName: payload.firstName,
      lastName: payload.lastName,
      phoneNumber: payload.phoneNumber,
      passwordHash,
      role: UserRole.DOCTOR,
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

  async registerPatient(payload: RegisterPatientDto) {
    const passwordHash = await bcrypt.hash(payload.password, 10);
    const user = await this.createUserSafely({
      email: payload.email.toLowerCase(),
      firstName: payload.firstName,
      lastName: payload.lastName,
      phoneNumber: payload.phoneNumber,
      passwordHash,
      role: UserRole.PATIENT,
      patient: {
        create: {
          dateOfBirth: new Date(payload.dateOfBirth),
          gender: payload.gender,
          genderAtBirth: payload.genderAtBirth,
          houseNumber: payload.address.houseNumber,
          street: payload.address.street,
          postcode: payload.address.postcode,
          highBloodPressure: payload.medicalHistory?.highBloodPressure ?? false,
          diabetes: payload.medicalHistory?.diabetes ?? false,
          heartDisease: payload.medicalHistory?.heartDisease ?? false,
          asthma: payload.medicalHistory?.asthma ?? false,
          allergies: payload.medicalHistory?.allergies ?? false,
          allergyDetails: payload.medicalHistory?.allergyDetails,
          currentMedications: payload.medicalHistory?.currentMedications,
          additionalNotes: payload.medicalHistory?.additionalNotes,
          sameGenderDoctorPreference:
            payload.preferences?.sameGenderDoctorPreference ?? false,
          locationServicesEnabled:
            payload.preferences?.locationServicesEnabled ?? true,
        },
      },
    });

    return this.issueAuthResponse(user, 'Patient registration successful');
  }

  async login(payload: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: payload.email.toLowerCase() },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const valid = await bcrypt.compare(payload.password, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.issueAuthResponse(user, 'Login successful');
  }

  async refresh(payload: RefreshTokenDto) {
    const tokenHash = hashRefreshToken(payload.refreshToken);
    const session = await this.prisma.session.findFirst({
      where: { refreshTokenHash: tokenHash },
      include: { user: true },
    });

    if (!session || session.expiresAt < new Date()) {
      if (session) {
        await this.prisma.session.delete({ where: { id: session.id } });
      }
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    await this.prisma.session.delete({ where: { id: session.id } });
    return this.issueAuthResponse(session.user, 'Token refreshed');
  }

  async logout(payload: RefreshTokenDto) {
    const tokenHash = hashRefreshToken(payload.refreshToken);
    await this.prisma.session.deleteMany({
      where: { refreshTokenHash: tokenHash },
    });
    return { success: true, message: 'Logged out' };
  }

  async forgotPassword(payload: ForgotPasswordDto) {
    const email = payload.email.toLowerCase();
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (user) {
      await this.prisma.passwordReset.deleteMany({
        where: { userId: user.id },
      });

      const token = generatePasswordResetToken();
      const expiresIn =
        this.configService.get<string>('PASSWORD_RESET_EXPIRES_IN') ?? '1h';

      await this.prisma.passwordReset.create({
        data: {
          userId: user.id,
          tokenHash: hashPasswordResetToken(token),
          expiresAt: expiresAtFromDuration(expiresIn),
        },
      });

      this.passwordResetMailer.sendPasswordResetEmail(user.email, token);
    }

    return {
      success: true,
      message:
        'If an account exists for this email, you will receive password reset instructions shortly.',
    };
  }

  async resetPassword(payload: ResetPasswordDto) {
    const email = payload.email.toLowerCase();
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    const tokenHash = hashPasswordResetToken(payload.token);
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
      throw new BadRequestException('Invalid or expired reset token');
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
      message:
        'Password updated successfully. You can sign in with your new password.',
    };
  }

  private async createUserSafely(
    data: Parameters<PrismaService['user']['create']>[0]['data'],
  ): Promise<User> {
    try {
      return await this.prisma.user.create({
        data: {
          ...data,
          verificationStatus: VerificationStatus.PENDING,
        },
      });
    } catch (error) {
      if (
        typeof error === 'object' &&
        error !== null &&
        'code' in error &&
        (error as { code: string }).code === 'P2002'
      ) {
        throw new ConflictException('Email already registered');
      }
      throw error;
    }
  }

  private async issueAuthResponse(user: User, message: string) {
    const accessToken = await this.issueAccessToken(
      user.id,
      user.email,
      user.role,
    );
    const refreshToken = await this.createRefreshSession(user.id);

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
        verificationStatus: user.verificationStatus.toLowerCase(),
        token: accessToken,
      },
    };
  }

  private async createRefreshSession(userId: string): Promise<string> {
    const refreshToken = generateRefreshToken();
    const refreshExpiresIn = this.configService.getOrThrow<string>(
      'JWT_REFRESH_EXPIRES_IN',
    );

    await this.prisma.session.create({
      data: {
        userId,
        refreshTokenHash: hashRefreshToken(refreshToken),
        expiresAt: expiresAtFromDuration(refreshExpiresIn),
      },
    });

    return refreshToken;
  }

  private async issueAccessToken(
    userId: string,
    email: string,
    role: UserRole,
  ) {
    return this.jwtService.signAsync(
      {
        sub: userId,
        email,
        role,
      },
      {
        secret: this.configService.getOrThrow<string>('JWT_SECRET'),
        expiresIn: this.configService.getOrThrow<string>(
          'JWT_EXPIRES_IN',
        ) as never,
      },
    );
  }
}
