import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DoctorsService } from './doctors.service';
import { UpdateDoctorAvailabilityDto } from './dto/update-doctor-availability.dto';
import type { JwtUser } from '../common/decorators/current-user.decorator';

@Controller('doctors')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DoctorsController {
  constructor(private readonly doctorsService: DoctorsService) {}

  @Get('me')
  @Roles('DOCTOR')
  getMe(@CurrentUser() user: JwtUser) {
    return this.doctorsService.getMe(user.sub);
  }

  @Patch('me/availability')
  @Roles('DOCTOR')
  updateAvailability(
    @CurrentUser() user: JwtUser,
    @Body() body: UpdateDoctorAvailabilityDto,
  ) {
    return this.doctorsService.updateAvailability(user.sub, body);
  }
}
