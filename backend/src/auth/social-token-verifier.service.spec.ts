import { ConfigService } from '@nestjs/config';
import { ServiceUnavailableException } from '@nestjs/common';
import { SocialTokenVerifierService } from './social-token-verifier.service';

function buildService(values: Record<string, string | undefined>) {
  const config = {
    get: jest.fn((key: string) => values[key]),
  } as unknown as ConfigService;
  return new SocialTokenVerifierService(config);
}

function unsignedToken(payload: Record<string, unknown>): string {
  const encode = (value: unknown) =>
    Buffer.from(JSON.stringify(value)).toString('base64url');
  return `${encode({ alg: 'none' })}.${encode(payload)}.`;
}

describe('SocialTokenVerifierService', () => {
  const forged = unsignedToken({
    sub: 'attacker',
    email: 'victim@example.com',
    email_verified: true,
  });

  it('refuses tokens when the provider audience is not configured', async () => {
    const service = buildService({ NODE_ENV: 'development' });

    await expect(service.verify('google', forged)).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });

  it('ignores the insecure flag in production', async () => {
    const service = buildService({
      NODE_ENV: 'production',
      ALLOW_INSECURE_SOCIAL_TOKENS: 'true',
    });

    await expect(service.verify('apple', forged)).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });

  it('accepts mock tokens only when the insecure flag is on outside production', async () => {
    const service = buildService({
      NODE_ENV: 'development',
      ALLOW_INSECURE_SOCIAL_TOKENS: 'true',
    });

    const claims = await service.verify('google', 'mock-google-token', {
      insecureFallbackEmail: 'dev@example.com',
    });

    expect(claims.email).toBe('dev@example.com');
    expect(claims.sub).toBe('google:mock-google-token');
  });
});
