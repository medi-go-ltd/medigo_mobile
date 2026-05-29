import { Injectable, NotFoundException } from '@nestjs/common';
import { AppointmentStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentStatusDto } from './dto/update-appointment-status.dto';

@Injectable()
export class AppointmentsService {
  constructor(private readonly prisma: PrismaService) {}

  async createForPatient(userId: string, payload: CreateAppointmentDto) {
    const patient = await this.prisma.patient.findUnique({ where: { userId } });
    if (!patient) {
      throw new NotFoundException('Patient profile not found');
    }

    return this.prisma.appointment.create({
      data: {
        patientId: patient.id,
        reasonForVisit: payload.reasonForVisit,
        bodyAreas: payload.bodyAreas ?? [],
        amount: payload.amount,
        bookingFor: payload.bookingFor ?? 'myself',
        otherPersonName: payload.otherPersonName,
        severeChestPain: payload.severeChestPain ?? false,
        difficultyBreath: payload.difficultyBreath ?? false,
        severePain: payload.severePain ?? false,
        unconscious: payload.unconscious ?? false,
        patientLat: payload.patientLat,
        patientLng: payload.patientLng,
      },
    });
  }

  listForPatient(userId: string) {
    return this.prisma.appointment.findMany({
      where: { patient: { userId } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listPendingForDoctor(userId: string) {
    const doctor = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!doctor) {
      throw new NotFoundException('Doctor profile not found');
    }

    return this.prisma.appointment.findMany({
      where: { status: AppointmentStatus.PENDING },
      orderBy: { createdAt: 'asc' },
      take: 50,
    });
  }

  async updateStatusForDoctor(
    userId: string,
    appointmentId: string,
    payload: UpdateAppointmentStatusDto,
  ) {
    const doctor = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!doctor) {
      throw new NotFoundException('Doctor profile not found');
    }

    const status = payload.status.toUpperCase() as AppointmentStatus;
    return this.prisma.appointment.update({
      where: { id: appointmentId },
      data: {
        doctorId: doctor.id,
        status,
        review: payload.review,
      },
    });
  }
}
