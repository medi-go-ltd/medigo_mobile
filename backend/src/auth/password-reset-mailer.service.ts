import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PasswordResetMailerService {
  private readonly logger = new Logger(PasswordResetMailerService.name);

  constructor(private readonly configService: ConfigService) {}

  async sendPasswordResetEmail(email: string, token: string): Promise<void> {
    const resetUrl = this.buildResetUrl(email, token);
    const nodeEnv = this.configService.get<string>('NODE_ENV') ?? 'development';

    if (nodeEnv !== 'production') {
      this.logger.log(
        `Password reset link for ${email}: ${resetUrl} (token: ${token})`,
      );
      return;
    }

    // Production email delivery can be wired to SendGrid, SES, etc.
    this.logger.warn(
      `Password reset email not sent in production (no mail provider configured) for ${email}`,
    );
  }

  private buildResetUrl(email: string, token: string): string {
    const baseUrl =
      this.configService.get<string>('PASSWORD_RESET_URL') ??
      'medigo://reset-password';
    const params = new URLSearchParams({ email, token });
    return `${baseUrl}?${params.toString()}`;
  }
}
