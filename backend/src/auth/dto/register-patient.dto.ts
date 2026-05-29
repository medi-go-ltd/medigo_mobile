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
  @IsString()
  houseNumber!: string;

  @IsString()
  street!: string;

  @IsString()
  postcode!: string;
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

  @IsDateString()
  dateOfBirth!: string;

  @IsString()
  gender!: string;

  @IsString()
  genderAtBirth!: string;

  @IsEmail()
  email!: string;

  @IsString()
  phoneNumber!: string;

  @ValidateNested()
  @Type(() => AddressDto)
  address!: AddressDto;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => MedicalHistoryDto)
  medicalHistory?: MedicalHistoryDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => PreferencesDto)
  preferences?: PreferencesDto;
}
