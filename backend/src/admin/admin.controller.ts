import { Body, Controller, Get, Param, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { AdminService } from './admin.service';
import { UpdateVerificationDto } from './dto/update-verification.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('users')
  users() {
    return this.adminService.listUsers();
  }

  @Get('bookings')
  bookings() {
    return this.adminService.listBookings();
  }

  @Patch('users/:userId/verification')
  verification(
    @Param('userId') userId: string,
    @Body() body: UpdateVerificationDto,
  ) {
    return this.adminService.updateDoctorVerification(userId, body);
  }

  @Patch('bookings/:id/decline')
  declineBooking(@Param('id') appointmentId: string) {
    return this.adminService.moderateBooking(appointmentId, 'declined');
  }
}
