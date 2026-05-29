"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppointmentsService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../prisma/prisma.service");
let AppointmentsService = class AppointmentsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createForPatient(userId, payload) {
        const patient = await this.prisma.patient.findUnique({ where: { userId } });
        if (!patient) {
            throw new common_1.NotFoundException('Patient profile not found');
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
    listForPatient(userId) {
        return this.prisma.appointment.findMany({
            where: { patient: { userId } },
            orderBy: { createdAt: 'desc' },
        });
    }
    async listPendingForDoctor(userId) {
        const doctor = await this.prisma.doctor.findUnique({ where: { userId } });
        if (!doctor) {
            throw new common_1.NotFoundException('Doctor profile not found');
        }
        return this.prisma.appointment.findMany({
            where: { status: client_1.AppointmentStatus.PENDING },
            orderBy: { createdAt: 'asc' },
            take: 50,
        });
    }
    async updateStatusForDoctor(userId, appointmentId, payload) {
        const doctor = await this.prisma.doctor.findUnique({ where: { userId } });
        if (!doctor) {
            throw new common_1.NotFoundException('Doctor profile not found');
        }
        const status = payload.status.toUpperCase();
        return this.prisma.appointment.update({
            where: { id: appointmentId },
            data: {
                doctorId: doctor.id,
                status,
                review: payload.review,
            },
        });
    }
};
exports.AppointmentsService = AppointmentsService;
exports.AppointmentsService = AppointmentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AppointmentsService);
//# sourceMappingURL=appointments.service.js.map