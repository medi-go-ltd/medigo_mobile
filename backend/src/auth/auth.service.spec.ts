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
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  const prisma = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
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

  it('logout deletes session by token hash', async () => {
    const refreshToken = generateRefreshToken();
    prisma.session.deleteMany.mockResolvedValue({ count: 1 });

    await service.logout({ refreshToken });

    expect(prisma.session.deleteMany).toHaveBeenCalledWith({
      where: { refreshTokenHash: hashRefreshToken(refreshToken) },
    });
  });
});
