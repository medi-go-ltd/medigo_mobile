import { createHash, randomBytes } from 'crypto';

export function generateRefreshToken(): string {
  return randomBytes(48).toString('hex');
}

export function hashRefreshToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export function generatePasswordResetToken(): string {
  return randomBytes(32).toString('hex');
}

export function hashPasswordResetToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

/** Six-digit numeric code for in-app email verification. */
export function generateEmailVerificationCode(): string {
  const n = randomBytes(3).readUIntBE(0, 3) % 1_000_000;
  return n.toString().padStart(6, '0');
}

export function hashEmailVerificationCode(code: string): string {
  return createHash('sha256').update(code.trim()).digest('hex');
}

export function parseDurationToMs(duration: string): number {
  const match = /^(\d+)([smhd])$/i.exec(duration.trim());
  if (!match) {
    return 3_600_000;
  }

  const value = Number(match[1]);
  const unit = match[2].toLowerCase();
  const multipliers: Record<string, number> = {
    s: 1000,
    m: 60_000,
    h: 3_600_000,
    d: 86_400_000,
  };
  return value * (multipliers[unit] ?? 3_600_000);
}

export function expiresAtFromDuration(duration: string): Date {
  return new Date(Date.now() + parseDurationToMs(duration));
}
