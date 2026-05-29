import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, VerificationStatus } from '@prisma/client';
import {
  generateRefreshToken,
  hashRefreshToken,
} from '../common/utils/token.util';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  const prisma = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    session: {
      findFirst: jest.fn(),
      create: jest.fn(),
      delete: jest.fn(),
      deleteMany: jest.fn(),
    },
  };

  const jwtService = {
    signAsync: jest.fn().mockResolvedValue('access-token'),
  };

  const configService = {
    getOrThrow: jest.fn((key: string) => {
      const values: Record<string, string> = {
        JWT_SECRET: 'test-secret',
        JWT_EXPIRES_IN: '1h',
        JWT_REFRESH_EXPIRES_IN: '7d',
      };
      return values[key];
    }),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prisma },
        { provide: JwtService, useValue: jwtService },
        { provide: ConfigService, useValue: configService },
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

  it('logout deletes session by token hash', async () => {
    const refreshToken = generateRefreshToken();
    prisma.session.deleteMany.mockResolvedValue({ count: 1 });

    await service.logout({ refreshToken });

    expect(prisma.session.deleteMany).toHaveBeenCalledWith({
      where: { refreshTokenHash: hashRefreshToken(refreshToken) },
    });
  });
});
