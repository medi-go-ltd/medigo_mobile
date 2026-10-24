import {
  IsBoolean,
  IsDateString,
  IsEmail,
  IsOptional,
  IsString,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class AddressDto {
  @IsOptional()
  @IsString()
  houseNumber?: string;

  @IsOptional()
  @IsString()
  street?: string;

  @IsOptional()
  @IsString()
  postcode?: string;
}

class MedicalHistoryDto {
  @IsOptional()
  @IsBoolean()
  highBloodPressure?: boolean;

  @IsOptional()
  @IsBoolean()
  diabetes?: boolean;

  @IsOptional()
  @IsBoolean()
  heartDisease?: boolean;

  @IsOptional()
  @IsBoolean()
  asthma?: boolean;

  @IsOptional()
  @IsBoolean()
  allergies?: boolean;

  @IsOptional()
  @IsString()
  allergyDetails?: string;

  @IsOptional()
  @IsString()
  currentMedications?: string;

  @IsOptional()
  @IsString()
  additionalNotes?: string;
}

class PreferencesDto {
  @IsOptional()
  @IsBoolean()
  sameGenderDoctorPreference?: boolean;

  @IsOptional()
  @IsBoolean()
  locationServicesEnabled?: boolean;
}

export class RegisterPatientDto {
  @IsString()
  firstName!: string;

  @IsString()
  lastName!: string;

  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsString()
  genderAtBirth?: string;

  @IsOptional()
  @IsString()
  phoneNumber?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => AddressDto)
  address?: AddressDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => MedicalHistoryDto)
  medicalHistory?: MedicalHistoryDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto;
}
