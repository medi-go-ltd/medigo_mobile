import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class EmailVerificationMailerService {
  private readonly logger = new Logger(EmailVerificationMailerService.name);

  constructor(private readonly configService: ConfigService) {}

  sendVerificationEmail(email: string, code: string): void {
    const nodeEnv = this.configService.get<string>('NODE_ENV') ?? 'development';

    if (nodeEnv !== 'production') {
      this.logger.log(
        `Email verification code for ${email}: ${code}`,
      );
      return;
    }

    // Production email delivery can be wired to SendGrid, SES, etc.
    this.logger.warn(
      `Email verification not sent in production (no mail provider configured) for ${email}`,
    );
  }
}
