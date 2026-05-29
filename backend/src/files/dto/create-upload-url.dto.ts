import { IsString } from 'class-validator';

export class CreateUploadUrlDto {
  @IsString()
  fileName!: string;

  @IsString()
  category!: string;
}
