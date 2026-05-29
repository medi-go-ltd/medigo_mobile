import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateDoctorAvailabilityDto } from './dto/update-doctor-availability.dto';

@Injectable()
export class DoctorsService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(userId: string) {
    const doctor = await this.prisma.doctor.findUnique({
      where: { userId },
      include: { user: true },
    });
    if (!doctor) {
      throw new NotFoundException('Doctor profile not found');
    }
    return doctor;
  }

  async updateAvailability(
    userId: string,
    payload: UpdateDoctorAvailabilityDto,
  ) {
    const doctor = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!doctor) {
      throw new NotFoundException('Doctor profile not found');
    }

    return this.prisma.doctor.update({
      where: { id: doctor.id },
      data: {
        isAvailable: payload.isAvailable ?? doctor.isAvailable,
        radiusKm: payload.radiusKm ?? doctor.radiusKm,
      },
    });
  }
}
