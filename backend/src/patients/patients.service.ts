import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdatePatientPreferencesDto } from './dto/update-patient-preferences.dto';

@Injectable()
export class PatientsService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(userId: string) {
    const patient = await this.prisma.patient.findUnique({
      where: { userId },
      include: { user: true },
    });

    if (!patient) {
      throw new NotFoundException('Patient profile not found');
    }

    return patient;
  }

  async updatePreferences(
    userId: string,
    payload: UpdatePatientPreferencesDto,
  ) {
    const patient = await this.prisma.patient.findUnique({ where: { userId } });
    if (!patient) {
      throw new NotFoundException('Patient profile not found');
    }

    return this.prisma.patient.update({
      where: { id: patient.id },
      data: {
        sameGenderDoctorPreference:
          payload.sameGenderDoctorPreference ??
          patient.sameGenderDoctorPreference,
        locationServicesEnabled:
          payload.locationServicesEnabled ?? patient.locationServicesEnabled,
        additionalNotes: payload.additionalNotes ?? patient.additionalNotes,
      },
    });
  }
}
