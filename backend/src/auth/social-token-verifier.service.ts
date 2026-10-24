import { createHash } from 'crypto';
import {
  Injectable,
  Logger,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createRemoteJWKSet, jwtVerify, type JWTPayload } from 'jose';

export type SocialProvider = 'google' | 'apple';

export interface VerifiedSocialClaims {
  sub: string;
  email?: string;
  emailVerified: boolean;
  firstName?: string;
  lastName?: string;
}

const GOOGLE_JWKS = createRemoteJWKSet(
  new URL('https://www.googleapis.com/oauth2/v3/certs'),
);
const APPLE_JWKS = createRemoteJWKSet(
  new URL('https://appleid.apple.com/auth/keys'),
);
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];
const APPLE_ISSUER = 'https://appleid.apple.com';

@Injectable()
export class SocialTokenVerifierService {
  private readonly logger = new Logger(SocialTokenVerifierService.name);

  constructor(private readonly configService: ConfigService) {}

  async verify(
    provider: SocialProvider,
    idToken: string,
    options: { rawNonce?: string; insecureFallbackEmail?: string } = {},
  ): Promise<VerifiedSocialClaims> {
    if (this.allowInsecureTokens()) {
      const claims = this.decodeWithoutVerification(provider, idToken);
      return { ...claims, email: claims.email ?? options.insecureFallbackEmail };
    }
    const { rawNonce } = options;

    const audience = this.audiencesFor(provider);
    if (audience.length === 0) {
      throw new ServiceUnavailableException(
        `${provider === 'google' ? 'Google' : 'Apple'} sign-in is not configured`,
      );
    }

    let payload: JWTPayload;
    try {
      const result = await jwtVerify(
        idToken,
        provider === 'google' ? GOOGLE_JWKS : APPLE_JWKS,
        {
          issuer: provider === 'google' ? GOOGLE_ISSUERS : APPLE_ISSUER,
          audience,
        },
      );
      payload = result.payload;
    } catch (error) {
      this.logger.warn(
        `Rejected ${provider} token: ${(error as Error).message}`,
      );
      throw new UnauthorizedException('Invalid social token');
    }

    if (provider === 'apple' && typeof payload.nonce === 'string') {
      const expected = rawNonce
        ? createHash('sha256').update(rawNonce).digest('hex')
        : null;
      if (expected !== payload.nonce) {
        throw new UnauthorizedException('Invalid social token');
      }
    }

    return this.toClaims(payload);
  }

  private toClaims(payload: JWTPayload): VerifiedSocialClaims {
    if (typeof payload.sub !== 'string' || payload.sub.length === 0) {
      throw new UnauthorizedException('Invalid social token');
    }
    const emailVerified =
      payload.email_verified === true || payload.email_verified === 'true';
    return {
      sub: payload.sub,
      email: typeof payload.email === 'string' ? payload.email : undefined,
      emailVerified,
      firstName:
        typeof payload.given_name === 'string' ? payload.given_name : undefined,
      lastName:
        typeof payload.family_name === 'string'
          ? payload.family_name
          : undefined,
    };
  }

  private audiencesFor(provider: SocialProvider): string[] {
    const raw =
      provider === 'google'
        ? this.configService.get<string>('GOOGLE_CLIENT_IDS')
        : this.configService.get<string>('APPLE_CLIENT_IDS');
    return (raw ?? '')
      .split(',')
      .map((value) => value.trim())
      .filter((value) => value.length > 0);
  }

  /**
   * Local development only: accepts unsigned/mock tokens so the app can be
   * exercised without real Google/Apple credentials. Never honoured in production.
   */
  private allowInsecureTokens(): boolean {
    const nodeEnv = this.configService.get<string>('NODE_ENV');
    const flag = this.configService.get<string>('ALLOW_INSECURE_SOCIAL_TOKENS');
    return nodeEnv !== 'production' && flag === 'true';
  }

  private decodeWithoutVerification(
    provider: SocialProvider,
    idToken: string,
  ): VerifiedSocialClaims {
    const parts = idToken.split('.');
    if (parts.length >= 2) {
      try {
        const json = Buffer.from(
          parts[1].replace(/-/g, '+').replace(/_/g, '/'),
          'base64',
        ).toString('utf8');
        const payload = JSON.parse(json) as JWTPayload;
        if (typeof payload.sub === 'string' && payload.sub.length > 0) {
          return { ...this.toClaims(payload), emailVerified: true };
        }
      } catch {
        // Fall through to opaque mock token handling.
      }
    }
    return {
      sub: `${provider}:${idToken.slice(0, 64)}`,
      emailVerified: true,
    };
  }
}
