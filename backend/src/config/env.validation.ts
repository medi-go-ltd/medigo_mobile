import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class EnvironmentVariables {
  @IsString()
  NODE_ENV!: string;

  @IsInt()
  @Min(1)
  @Max(65535)
  PORT!: number;

  @IsString()
  API_PREFIX!: string;

  @IsString()
  DATABASE_URL!: string;

  @IsString()
  JWT_SECRET!: string;

  @IsString()
  JWT_EXPIRES_IN!: string;

  @IsString()
  JWT_REFRESH_SECRET!: string;

  @IsString()
  JWT_REFRESH_EXPIRES_IN!: string;

  @IsInt()
  THROTTLE_TTL!: number;

  @IsInt()
  THROTTLE_LIMIT!: number;

  @IsOptional()
  @IsString()
  UPLOAD_BUCKET?: string;

  @IsOptional()
  @IsString()
  UPLOAD_BASE_URL?: string;

  @IsOptional()
  @IsString()
  GOOGLE_CLIENT_IDS?: string;

  @IsOptional()
  @IsString()
  APPLE_CLIENT_IDS?: string;

  @IsOptional()
  @IsString()
  ALLOW_INSECURE_SOCIAL_TOKENS?: string;
}
