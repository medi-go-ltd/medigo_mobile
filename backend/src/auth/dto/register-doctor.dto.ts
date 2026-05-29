import {
  IsArray,
  IsBoolean,
  IsEmail,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MinLength,
} from 'class-validator';

export class RegisterDoctorDto {
  @IsString()
  firstName!: string;

  @IsString()
  lastName!: string;

  @IsEmail()
  email!: string;

  @IsString()
  phoneNumber!: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsOptional()
  @IsString()
  profileImagePath?: string;

  @IsString()
  homeAddress!: string;

  @IsString()
  gmcNumber!: string;

  @IsArray()
  @IsString({ each: true })
  specialisations!: string[];

  @IsNumber()
  @Min(0)
  yearsOfExperience!: number;

  @IsNumber()
  @Min(0)
  consultationFee!: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  callOutFee?: number;

  @IsNumber()
  @Min(0)
  radiusKm!: number;

  @IsArray()
  @IsString({ each: true })
  qualificationsFilePaths!: string[];

  @IsOptional()
  @IsString()
  photoIdFilePath?: string;

  @IsBoolean()
  dbsConsentGiven!: boolean;
}
