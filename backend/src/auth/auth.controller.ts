import { Body, Controller, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiOkResponse,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDoctorDto } from './dto/register-doctor.dto';
import { RegisterPatientDto } from './dto/register-patient.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import {
  AuthResponseDto,
  MessageResponseDto,
} from '../common/dto/auth-response.dto';

@ApiTags('auth')
@Controller()
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('doctors/register')
  @ApiOkResponse({ type: AuthResponseDto })
  @ApiConflictResponse({ description: 'Email already registered' })
  registerDoctor(@Body() body: RegisterDoctorDto) {
    return this.authService.registerDoctor(body);
  }

  @Post('patients/register')
  @ApiOkResponse({ type: AuthResponseDto })
  @ApiConflictResponse({ description: 'Email already registered' })
  registerPatient(@Body() body: RegisterPatientDto) {
    return this.authService.registerPatient(body);
  }

  @Post('login')
  @ApiOkResponse({ type: AuthResponseDto })
  @ApiUnauthorizedResponse({ description: 'Invalid credentials' })
  login(@Body() body: LoginDto) {
    return this.authService.login(body);
  }

  @Post('auth/refresh')
  @ApiOkResponse({ type: AuthResponseDto })
  @ApiUnauthorizedResponse({ description: 'Invalid or expired refresh token' })
  refresh(@Body() body: RefreshTokenDto) {
    return this.authService.refresh(body);
  }

  @Post('auth/logout')
  @ApiOkResponse({ type: MessageResponseDto })
  logout(@Body() body: RefreshTokenDto) {
    return this.authService.logout(body);
  }

  @Post('auth/forgot-password')
  @ApiOkResponse({ type: MessageResponseDto })
  forgotPassword(@Body() body: ForgotPasswordDto) {
    return this.authService.forgotPassword(body);
  }

  @Post('auth/reset-password')
  @ApiOkResponse({ type: MessageResponseDto })
  resetPassword(@Body() body: ResetPasswordDto) {
    return this.authService.resetPassword(body);
  }
}
