import { ApiProperty } from '@nestjs/swagger';
import { IsEmail } from 'class-validator';

export class ResendEmailVerificationDto {
  @ApiProperty({ example: 'patient@example.com' })
  @IsEmail()
  email!: string;
}
