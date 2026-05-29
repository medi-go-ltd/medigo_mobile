import { IsBoolean, IsNumber, IsOptional, Min } from 'class-validator';

export class UpdateDoctorAvailabilityDto {
  @IsOptional()
  @IsBoolean()
  isAvailable?: boolean;

  @IsOptional()
  @IsNumber()
  @Min(0)
  radiusKm?: number;
}
