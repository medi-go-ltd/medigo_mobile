import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ResetPasswordDto {
  @ApiProperty({ example: 'patient@example.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ description: 'Reset token from the password reset email' })
  @IsString()
  token!: string;

  @ApiProperty({ minLength: 8, example: 'SecurePass123!' })
  @IsString()
  @MinLength(8)
  password!: string;
}
