"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var SocialTokenVerifierService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SocialTokenVerifierService = void 0;
const crypto_1 = require("crypto");
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jose_1 = require("jose");
const GOOGLE_JWKS = (0, jose_1.createRemoteJWKSet)(new URL('https://www.googleapis.com/oauth2/v3/certs'));
const APPLE_JWKS = (0, jose_1.createRemoteJWKSet)(new URL('https://appleid.apple.com/auth/keys'));
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];
const APPLE_ISSUER = 'https://appleid.apple.com';
let SocialTokenVerifierService = SocialTokenVerifierService_1 = class SocialTokenVerifierService {
    configService;
    logger = new common_1.Logger(SocialTokenVerifierService_1.name);
    constructor(configService) {
        this.configService = configService;
    }
    async verify(provider, idToken, options = {}) {
        if (this.allowInsecureTokens()) {
            const claims = this.decodeWithoutVerification(provider, idToken);
            return { ...claims, email: claims.email ?? options.insecureFallbackEmail };
        }
        const { rawNonce } = options;
        const audience = this.audiencesFor(provider);
        if (audience.length === 0) {
            throw new common_1.ServiceUnavailableException(`${provider === 'google' ? 'Google' : 'Apple'} sign-in is not configured`);
        }
        let payload;
        try {
            const result = await (0, jose_1.jwtVerify)(idToken, provider === 'google' ? GOOGLE_JWKS : APPLE_JWKS, {
                issuer: provider === 'google' ? GOOGLE_ISSUERS : APPLE_ISSUER,
                audience,
            });
            payload = result.payload;
        }
        catch (error) {
            this.logger.warn(`Rejected ${provider} token: ${error.message}`);
            throw new common_1.UnauthorizedException('Invalid social token');
        }
        if (provider === 'apple' && typeof payload.nonce === 'string') {
            const expected = rawNonce
                ? (0, crypto_1.createHash)('sha256').update(rawNonce).digest('hex')
                : null;
            if (expected !== payload.nonce) {
                throw new common_1.UnauthorizedException('Invalid social token');
            }
        }
        return this.toClaims(payload);
    }
    toClaims(payload) {
        if (typeof payload.sub !== 'string' || payload.sub.length === 0) {
            throw new common_1.UnauthorizedException('Invalid social token');
        }
        const emailVerified = payload.email_verified === true || payload.email_verified === 'true';
        return {
            sub: payload.sub,
            email: typeof payload.email === 'string' ? payload.email : undefined,
            emailVerified,
            firstName: typeof payload.given_name === 'string' ? payload.given_name : undefined,
            lastName: typeof payload.family_name === 'string'
                ? payload.family_name
                : undefined,
        };
    }
    audiencesFor(provider) {
        const raw = provider === 'google'
            ? this.configService.get('GOOGLE_CLIENT_IDS')
            : this.configService.get('APPLE_CLIENT_IDS');
        return (raw ?? '')
            .split(',')
            .map((value) => value.trim())
            .filter((value) => value.length > 0);
    }
    allowInsecureTokens() {
        const nodeEnv = this.configService.get('NODE_ENV');
        const flag = this.configService.get('ALLOW_INSECURE_SOCIAL_TOKENS');
        return nodeEnv !== 'production' && flag === 'true';
    }
    decodeWithoutVerification(provider, idToken) {
        const parts = idToken.split('.');
        if (parts.length >= 2) {
            try {
                const json = Buffer.from(parts[1].replace(/-/g, '+').replace(/_/g, '/'), 'base64').toString('utf8');
                const payload = JSON.parse(json);
                if (typeof payload.sub === 'string' && payload.sub.length > 0) {
                    return { ...this.toClaims(payload), emailVerified: true };
                }
            }
            catch {
            }
        }
        return {
            sub: `${provider}:${idToken.slice(0, 64)}`,
            emailVerified: true,
        };
    }
};
exports.SocialTokenVerifierService = SocialTokenVerifierService;
exports.SocialTokenVerifierService = SocialTokenVerifierService = SocialTokenVerifierService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], SocialTokenVerifierService);
//# sourceMappingURL=social-token-verifier.service.js.map