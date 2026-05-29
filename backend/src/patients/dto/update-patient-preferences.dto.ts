import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class UpdatePatientPreferencesDto {
  @IsOptional()
  @IsBoolean()
  sameGenderDoctorPreference?: boolean;

  @IsOptional()
  @IsBoolean()
  locationServicesEnabled?: boolean;

  @IsOptional()
  @IsString()
  additionalNotes?: string;
}
