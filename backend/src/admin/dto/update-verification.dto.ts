import { IsIn } from 'class-validator';

export class UpdateVerificationDto {
  @IsIn(['approved', 'rejected'])
  status!: 'approved' | 'rejected';
}
