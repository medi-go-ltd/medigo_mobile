import {
  IsArray,
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CreateAppointmentDto {
  @IsString()
  reasonForVisit!: string;

  @IsArray()
  @IsString({ each: true })
  bodyAreas!: string[];

  @IsNumber()
  amount!: number;

  @IsOptional()
  @IsString()
  bookingFor?: string;

  @IsOptional()
  @IsString()
  otherPersonName?: string;

  @IsOptional()
  @IsBoolean()
  severeChestPain?: boolean;

  @IsOptional()
  @IsBoolean()
  difficultyBreath?: boolean;

  @IsOptional()
  @IsBoolean()
  severePain?: boolean;

  @IsOptional()
  @IsBoolean()
  unconscious?: boolean;

  @IsOptional()
  @IsNumber()
  @Min(-90)
  @Max(90)
  patientLat?: number;

  @IsOptional()
  @IsNumber()
  @Min(-180)
  @Max(180)
  patientLng?: number;
}
