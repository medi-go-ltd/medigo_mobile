import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, VerificationStatus } from '@prisma/client';
import {
  generatePasswordResetToken,
  generateRefreshToken,
  hashPasswordResetToken,
  hashRefreshToken,
} from '../common/utils/token.util';
import { PasswordResetMailerService } from './password-reset-mailer.service';
import { EmailVerificationMailerService } from './email-verification-mailer.service';
import { SocialTokenVerifierService } from './social-token-verifier.service';
import { hashEmailVerificationCode } from '../common/utils/token.util';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  const prisma = {
    user: {
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    patient: {
      findUnique: jest.fn().mockResolvedValue(null),
    },
    emailVerification: {
      findFirst: jest.fn(),
      create: jest.fn(),
      delete: jest.fn(),
      deleteMany: jest.fn(),
    },
    session: {
      findFirst: jest.fn(),
      create: jest.fn(),
      delete: jest.fn(),
      deleteMany: jest.fn(),
    },
    passwordReset: {
      findFirst: jest.fn(),
      create: jest.fn(),
      delete: jest.fn(),
      deleteMany: jest.fn(),
    },
    $transaction: jest.fn((operations: Promise<unknown>[]) =>
      Promise.all(operations),
    ),
  };

  const jwtService = {
    signAsync: jest.fn().mockResolvedValue('access-token'),
  };

  const configValues: Record<string, string> = {
    JWT_SECRET: 'test-secret',
    JWT_EXPIRES_IN: '1h',
    JWT_REFRESH_EXPIRES_IN: '7d',
    PASSWORD_RESET_EXPIRES_IN: '1h',
  };

  const configService = {
    get: jest.fn((key: string) => configValues[key]),
    getOrThrow: jest.fn((key: string) => {
      const value = configValues[key];
      if (!value) {
        throw new Error(`Missing config: ${key}`);
      }
      return value;
    }),
  };

  const passwordResetMailer = {
    sendPasswordResetEmail: jest.fn().mockResolvedValue(undefined),
  };

  const emailVerificationMailer = {
    sendVerificationEmail: jest.fn(),
  };

  const socialTokenVerifier = {
    verify: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prisma },
        { provide: JwtService, useValue: jwtService },
        { provide: ConfigService, useValue: configService },
        {
          provide: PasswordResetMailerService,
          useValue: passwordResetMailer,
        },
        {
          provide: EmailVerificationMailerService,
          useValue: emailVerificationMailer,
        },
        {
          provide: SocialTokenVerifierService,
          useValue: socialTokenVerifier,
        },
      ],
    }).compile();

    service = module.get(AuthService);
  });

  it('login returns access and refresh tokens', async () => {
    const password = 'password';
    const passwordHash = await bcrypt.hash(password, 4);
    prisma.user.findUnique.mockResolvedValue({
      id: 'user-1',
      email: 'patient@example.com',
      passwordHash,
      firstName: 'Jane',
      lastName: 'Doe',
      phoneNumber: null,
      role: UserRole.PATIENT,
      verificationStatus: VerificationStatus.PENDING,
    });
    prisma.session.create.mockResolvedValue({});

    const result = await service.login({
      email: 'patient@example.com',
      password,
    });

    expect(result.success).toBe(true);
    expect(result.user.token).toBe('access-token');
    expect(result.refreshToken).toBeDefined();
    expect(prisma.session.create).toHaveBeenCalled();
  });

  it('refresh rotates session and returns new tokens', async () => {
    const refreshToken = generateRefreshToken();
    const user = {
      id: 'user-1',
      email: 'patient@example.com',
      firstName: 'Jane',
      lastName: 'Doe',
      phoneNumber: null,
      role: UserRole.PATIENT,
      verificationStatus: VerificationStatus.PENDING,
      passwordHash: 'hash',
    };

    prisma.session.findFirst.mockResolvedValue({
      id: 'session-1',
      expiresAt: new Date(Date.now() + 60_000),
      user,
    });
    prisma.session.delete.mockResolvedValue({});
    prisma.session.create.mockResolvedValue({});

    const result = await service.refresh({ refreshToken });

    expect(prisma.session.delete).toHaveBeenCalledWith({
      where: { id: 'session-1' },
    });
    expect(result.refreshToken).toBeDefined();
    expect(result.refreshToken).not.toBe(refreshToken);
  });

  it('refresh rejects expired session', async () => {
    prisma.session.findFirst.mockResolvedValue({
      id: 'session-1',
      expiresAt: new Date(Date.now() - 60_000),
      user: { id: 'user-1' },
    });
    prisma.session.delete.mockResolvedValue({});

    await expect(
      service.refresh({ refreshToken: generateRefreshToken() }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('forgotPassword returns generic message when user does not exist', async () => {
    prisma.user.findUnique.mockResolvedValue(null);

    const result = await service.forgotPassword({
      email: 'missing@example.com',
    });

    expect(result.success).toBe(true);
    expect(prisma.passwordReset.create).not.toHaveBeenCalled();
    expect(passwordResetMailer.sendPasswordResetEmail).not.toHaveBeenCalled();
  });

  it('forgotPassword creates reset token for existing user', async () => {
    prisma.user.findUnique.mockResolvedValue({
      id: 'user-1',
      email: 'patient@example.com',
    });
    prisma.passwordReset.deleteMany.mockResolvedValue({ count: 0 });
    prisma.passwordReset.create.mockResolvedValue({});

    const result = await service.forgotPassword({
      email: 'patient@example.com',
    });

    expect(result.success).toBe(true);
    expect(prisma.passwordReset.create).toHaveBeenCalled();
    expect(passwordResetMailer.sendPasswordResetEmail).toHaveBeenCalled();
  });

  it('resetPassword updates password for valid token', async () => {
    const token = generatePasswordResetToken();
    const passwordHash = await bcrypt.hash('old-password', 4);
    prisma.user.findUnique.mockResolvedValue({
      id: 'user-1',
      email: 'patient@example.com',
      passwordHash,
    });
    prisma.passwordReset.findFirst.mockResolvedValue({
      id: 'reset-1',
      expiresAt: new Date(Date.now() + 60_000),
      tokenHash: hashPasswordResetToken(token),
    });
    prisma.user.update.mockResolvedValue({});
    prisma.passwordReset.deleteMany.mockResolvedValue({ count: 1 });
    prisma.session.deleteMany.mockResolvedValue({ count: 0 });

    const result = await service.resetPassword({
      email: 'patient@example.com',
      token,
      password: 'NewSecure123!',
    });

    expect(result.success).toBe(true);
    expect(prisma.user.update).toHaveBeenCalled();
  });

  it('resetPassword rejects invalid token', async () => {
    prisma.user.findUnique.mockResolvedValue({
      id: 'user-1',
      email: 'patient@example.com',
      passwordHash: 'hash',
    });
    prisma.passwordReset.findFirst.mockResolvedValue(null);

    await expect(
      service.resetPassword({
        email: 'patient@example.com',
        token: 'invalid-token',
        password: 'NewSecure123!',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  describe('verifyEmail', () => {
    const unverifiedUser = {
      id: 'user-1',
      email: 'patient@example.com',
      firstName: 'Jane',
      lastName: 'Doe',
      phoneNumber: null,
      profileImageUrl: null,
      role: UserRole.PATIENT,
      verificationStatus: VerificationStatus.APPROVED,
      emailVerifiedAt: null,
    };

    it('rejects an already verified email without issuing a session', async () => {
      prisma.user.findUnique.mockResolvedValue({
        ...unverifiedUser,
        emailVerifiedAt: new Date(),
      });

      await expect(
        service.verifyEmail({ email: 'patient@example.com', code: '000000' }),
      ).rejects.toBeInstanceOf(BadRequestException);
      expect(prisma.session.create).not.toHaveBeenCalled();
    });

    it('rejects a wrong code', async () => {
      prisma.user.findUnique.mockResolvedValue(unverifiedUser);
      prisma.emailVerification.findFirst.mockResolvedValue(null);

      await expect(
        service.verifyEmail({ email: 'patient@example.com', code: '000000' }),
      ).rejects.toBeInstanceOf(BadRequestException);
      expect(prisma.session.create).not.toHaveBeenCalled();
    });

    it('marks the email verified and issues a session for a valid code', async () => {
      prisma.user.findUnique.mockResolvedValue(unverifiedUser);
      prisma.emailVerification.findFirst.mockResolvedValue({
        id: 'ev-1',
        codeHash: hashEmailVerificationCode('123456'),
        expiresAt: new Date(Date.now() + 60_000),
      });
      prisma.user.update.mockResolvedValue({
        ...unverifiedUser,
        emailVerifiedAt: new Date(),
      });
      prisma.emailVerification.deleteMany.mockResolvedValue({ count: 1 });
      prisma.session.create.mockResolvedValue({});

      const result = await service.verifyEmail({
        email: 'patient@example.com',
        code: '123456',
      });

      expect(result.user.emailVerified).toBe(true);
      expect(result.user.token).toBe('access-token');
    });
  });

  describe('socialSignIn', () => {
    it('uses the email from the verified token, not the request body', async () => {
      socialTokenVerifier.verify.mockResolvedValue({
        sub: 'google-sub-1',
        email: 'real@example.com',
        emailVerified: true,
      });
      prisma.user.findFirst.mockResolvedValue(null);
      prisma.user.findUnique.mockResolvedValue(null);
      prisma.user.create.mockImplementation(
        ({ data }: { data: Record<string, unknown> }) =>
          Promise.resolve({
            id: 'user-2',
            phoneNumber: null,
            profileImageUrl: null,
            verificationStatus: VerificationStatus.APPROVED,
            ...data,
          }),
      );
      prisma.session.create.mockResolvedValue({});

      const result = await service.socialSignIn({
        provider: 'google',
        idToken: 'token',
        role: 'patient',
        email: 'victim@example.com',
      });

      expect(result.user.email).toBe('real@example.com');
    });

    it('rejects provider emails that are not verified', async () => {
      socialTokenVerifier.verify.mockResolvedValue({
        sub: 'google-sub-1',
        email: 'real@example.com',
        emailVerified: false,
      });

      await expect(
        service.socialSignIn({
          provider: 'google',
          idToken: 'token',
          role: 'patient',
        }),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });
  });

  it('logout deletes session by token hash', async () => {
    const refreshToken = generateRefreshToken();
    prisma.session.deleteMany.mockResolvedValue({ count: 1 });

    await service.logout({ refreshToken });

    expect(prisma.session.deleteMany).toHaveBeenCalledWith({
      where: { refreshTokenHash: hashRefreshToken(refreshToken) },
    });
  });
});
