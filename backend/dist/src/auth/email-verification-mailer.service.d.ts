import { ConfigService } from '@nestjs/config';
export declare class EmailVerificationMailerService {
    private readonly configService;
    private readonly logger;
    constructor(configService: ConfigService);
    sendVerificationEmail(email: string, code: string): void;
}
