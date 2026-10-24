import { IsEmail, IsIn, IsOptional, IsString } from 'class-validator';

export class SocialSignInDto {
  @IsIn(['google', 'apple'])
  provider!: 'google' | 'apple';

  @IsString()
  idToken!: string;

  @IsIn(['patient'])
  role!: 'patient';

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  firstName?: string;

  @IsOptional()
  @IsString()
  lastName?: string;

  @IsOptional()
  @IsString()
  nonce?: string;
}
