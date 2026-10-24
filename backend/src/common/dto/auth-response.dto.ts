import { ApiProperty } from '@nestjs/swagger';

export class AuthUserDto {
  @ApiProperty({ example: 'clxyz123' })
  id!: string;

  @ApiProperty({ example: 'patient@example.com' })
  email!: string;

  @ApiProperty({ example: 'Jane' })
  firstName!: string;

  @ApiProperty({ example: 'Doe' })
  lastName!: string;

  @ApiProperty({ example: '+447700900123', nullable: true })
  phoneNumber!: string | null;

  @ApiProperty({ example: 'patient', enum: ['patient', 'doctor', 'admin'] })
  role!: string;

  @ApiProperty({
    example: 'pending',
    enum: ['pending', 'approved', 'rejected'],
  })
  verificationStatus!: string;

  @ApiProperty({
    example: false,
    description: 'Whether the email address has been verified',
  })
  emailVerified!: boolean;

  @ApiProperty({ description: 'JWT access token' })
  token!: string;
}

export class AuthResponseDto {
  @ApiProperty({ example: true })
  success!: boolean;

  @ApiProperty({ example: 'Login successful' })
  message!: string;

  @ApiProperty({ type: AuthUserDto })
  user!: AuthUserDto;

  @ApiProperty({
    description: 'Opaque refresh token for rotation via POST /auth/refresh',
  })
  refreshToken!: string;
}

export class RefreshTokenRequestDto {
  @ApiProperty()
  refreshToken!: string;
}

export class MessageResponseDto {
  @ApiProperty({ example: true })
  success!: boolean;

  @ApiProperty({ example: 'Logged out' })
  message!: string;
}
