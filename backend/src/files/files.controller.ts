import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FilesService } from './files.service';
import { CreateUploadUrlDto } from './dto/create-upload-url.dto';

@Controller('files')
@UseGuards(JwtAuthGuard)
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Post('presigned-upload')
  presignedUpload(@Body() body: CreateUploadUrlDto) {
    return this.filesService.createPresignedUpload(
      body.fileName,
      body.category,
    );
  }
}
