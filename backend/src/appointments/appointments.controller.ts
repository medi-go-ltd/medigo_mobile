import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { RolesGuard } from '../common/guards/roles.guard';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentStatusDto } from './dto/update-appointment-status.dto';
import type { JwtUser } from '../common/decorators/current-user.decorator';

@Controller('appointments')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AppointmentsController {
  constructor(private readonly appointmentsService: AppointmentsService) {}

  @Post()
  @Roles('PATIENT')
  create(@CurrentUser() user: JwtUser, @Body() body: CreateAppointmentDto) {
    return this.appointmentsService.createForPatient(user.sub, body);
  }

  @Get('me')
  @Roles('PATIENT')
  myAppointments(@CurrentUser() user: JwtUser) {
    return this.appointmentsService.listForPatient(user.sub);
  }

  @Get('doctor/pending')
  @Roles('DOCTOR')
  doctorPending(@CurrentUser() user: JwtUser) {
    return this.appointmentsService.listPendingForDoctor(user.sub);
  }

  @Patch(':id/status')
  @Roles('DOCTOR')
  updateStatus(
    @CurrentUser() user: JwtUser,
    @Param('id') appointmentId: string,
    @Body() body: UpdateAppointmentStatusDto,
  ) {
    return this.appointmentsService.updateStatusForDoctor(
      user.sub,
      appointmentId,
      body,
    );
  }
}
