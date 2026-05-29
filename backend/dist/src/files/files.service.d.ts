import { ConfigService } from '@nestjs/config';
export declare class FilesService {
    private readonly configService;
    constructor(configService: ConfigService);
    createPresignedUpload(fileName: string, category: string): {
        uploadUrl: string;
        fileUrl: string;
        expiresIn: number;
    };
}
