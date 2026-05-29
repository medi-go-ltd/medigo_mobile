import { IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({
    description: 'Opaque refresh token from login/register response',
  })
  @IsString()
  @MinLength(32)
  refreshToken!: string;
}
