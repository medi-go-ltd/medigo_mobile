import { IsIn, IsOptional, IsString } from 'class-validator';

export class UpdateAppointmentStatusDto {
  @IsIn(['accepted', 'declined', 'en_route', 'in_progress', 'completed'])
  status!: string;

  @IsOptional()
  @IsString()
  review?: string;
}
