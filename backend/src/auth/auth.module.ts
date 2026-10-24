import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { JwtStrategy } from './jwt.strategy';
import { PasswordResetMailerService } from './password-reset-mailer.service';
import { EmailVerificationMailerService } from './email-verification-mailer.service';
import { SocialTokenVerifierService } from './social-token-verifier.service';

@Module({
  imports: [
    ConfigModule,
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.getOrThrow<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: config.getOrThrow<string>('JWT_EXPIRES_IN') as never,
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    PasswordResetMailerService,
    EmailVerificationMailerService,
    SocialTokenVerifierService,
  ],
  exports: [AuthService],
})
export class AuthModule {}
