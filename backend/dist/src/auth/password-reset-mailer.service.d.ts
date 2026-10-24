import { ConfigService } from '@nestjs/config';
export declare class PasswordResetMailerService {
    private readonly configService;
    private readonly logger;
    constructor(configService: ConfigService);
    sendPasswordResetEmail(email: string, token: string): void;
    private buildResetUrl;
}
