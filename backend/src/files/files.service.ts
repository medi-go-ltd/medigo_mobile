import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class FilesService {
  constructor(private readonly configService: ConfigService) {}

  createPresignedUpload(fileName: string, category: string) {
    const baseUrl =
      this.configService.get<string>('UPLOAD_BASE_URL') ??
      'https://files.medigo.local';
    const key = `${category}/${Date.now()}-${fileName}`;

    return {
      uploadUrl: `${baseUrl}/upload/${key}?signature=fake-dev-signature`,
      fileUrl: `${baseUrl}/${key}`,
      expiresIn: 900,
    };
  }
}
