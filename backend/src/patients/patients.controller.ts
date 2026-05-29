import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PatientsService } from './patients.service';
import { UpdatePatientPreferencesDto } from './dto/update-patient-preferences.dto';
import type { JwtUser } from '../common/decorators/current-user.decorator';

@Controller('patients')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PatientsController {
  constructor(private readonly patientsService: PatientsService) {}

  @Get('me')
  @Roles('PATIENT')
  getMe(@CurrentUser() user: JwtUser) {
    return this.patientsService.getMe(user.sub);
  }

  @Patch('me/preferences')
  @Roles('PATIENT')
  updatePreferences(
    @CurrentUser() user: JwtUser,
    @Body() body: UpdatePatientPreferencesDto,
  ) {
    return this.patientsService.updatePreferences(user.sub, body);
  }
}
