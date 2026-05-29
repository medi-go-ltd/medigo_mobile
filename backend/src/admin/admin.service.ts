import { Injectable } from '@nestjs/common';
import { AppointmentStatus, VerificationStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateVerificationDto } from './dto/update-verification.dto';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  listUsers() {
    return this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  listBookings() {
    return this.prisma.appointment.findMany({
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  updateDoctorVerification(userId: string, payload: UpdateVerificationDto) {
    const status =
      payload.status === 'approved'
        ? VerificationStatus.APPROVED
        : VerificationStatus.REJECTED;
    return this.prisma.user.update({
      where: { id: userId },
      data: { verificationStatus: status },
    });
  }

  moderateBooking(appointmentId: string, status: 'declined' | 'completed') {
    const mapped =
      status === 'declined'
        ? AppointmentStatus.DECLINED
        : AppointmentStatus.COMPLETED;
    return this.prisma.appointment.update({
      where: { id: appointmentId },
      data: { status: mapped },
    });
  }
}
