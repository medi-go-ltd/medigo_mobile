import { FilesService } from './files.service';
import { CreateUploadUrlDto } from './dto/create-upload-url.dto';
export declare class FilesController {
    private readonly filesService;
    constructor(filesService: FilesService);
    presignedUpload(body: CreateUploadUrlDto): {
        uploadUrl: string;
        fileUrl: string;
        expiresIn: number;
    };
}
