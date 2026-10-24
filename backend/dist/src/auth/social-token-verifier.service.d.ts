import { ConfigService } from '@nestjs/config';
export type SocialProvider = 'google' | 'apple';
export interface VerifiedSocialClaims {
    sub: string;
    email?: string;
    emailVerified: boolean;
    firstName?: string;
    lastName?: string;
}
export declare class SocialTokenVerifierService {
    private readonly configService;
    private readonly logger;
    constructor(configService: ConfigService);
    verify(provider: SocialProvider, idToken: string, options?: {
        rawNonce?: string;
        insecureFallbackEmail?: string;
    }): Promise<VerifiedSocialClaims>;
    private toClaims;
    private audiencesFor;
    private allowInsecureTokens;
    private decodeWithoutVerification;
}
